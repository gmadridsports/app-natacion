drop table if exists public.test_users cascade;
create table
    public.test_users
(
    email     text    not null,
    password  text    not null,
    is_member boolean not null,
    constraint test_users_pkey primary key (email)
) tablespace pg_default;

alter table public.test_users
    enable row level security;
create policy "test admin can add a user"
    on public.test_users
    for insert WITH CHECK (
    auth.jwt() ->> 'email' = 'test+admin@gmadridnatacion.bertamini.net'
    );

CREATE OR REPLACE FUNCTION public.insert_test_user()
    RETURNS trigger AS
$BODY$
declare
    new_id uuid := uuid_generate_v4();
BEGIN
    insert into "auth"."users" ("instance_id",
                                "id",
                                "aud",
                                "role",
                                "email",
                                "encrypted_password",
                                "email_confirmed_at",
                                "invited_at",
                                "confirmation_token",
                                "confirmation_sent_at",
                                "recovery_token",
                                "recovery_sent_at",
                                "email_change_token_new",
                                "email_change",
                                "email_change_sent_at",
                                "last_sign_in_at",
                                "raw_app_meta_data",
                                "raw_user_meta_data",
                                "is_super_admin",
                                "created_at",
                                "updated_at",
                                "phone",
                                "phone_confirmed_at",
                                "phone_change",
                                "phone_change_token",
                                "phone_change_sent_at",
                                "email_change_token_current",
                                "email_change_confirm_status",
                                "banned_until",
                                "reauthentication_token",
                                "reauthentication_sent_at",
                                "is_sso_user")
    values ('00000000-0000-0000-0000-000000000000',
            new_id,
            'authenticated',
            'authenticated',
            NEW.email,
            crypt(NEW.password, gen_salt('bf')),
            now(),
            null,
            '',
            now(),
            '',
            null,
            '',
            '',
            null,
            now(),
            '{"provider": "email", "providers": ["email"]}',
            '{}',
            null,
            now(),
            now(),
            null,
            null,
            '',
            '',
            null,
            '',
            0,
            null,
            '',
            null,
            'f');

    IF NEW.is_member THEN
        UPDATE public.profiles SET membership_level = 'member' WHERE id = new_id;
    END IF;
    RETURN NULL;
END;
$BODY$
    security definer
    LANGUAGE 'plpgsql';


create trigger on_auth_user_created
    BEFORE insert
    on public.test_users
    for each row
EXECUTE PROCEDURE insert_test_user();



--- empty test users every day
create or replace function delete_old_test_accounts()
    returns void as
$$
declare
    num_failed_test_users smallint := 0;
begin
    SELECT COUNT(email) INTO num_failed_test_users FROM public.test_users;

    IF num_failed_test_users = 0 THEN
        delete
        from auth.users
        where id in (select id
                     from auth.users
                     where email <> 'test+admin@gmadridnatacion.bertamini.net'
                       and created_at < now() - interval '24 hours');
    ELSE
        RAISE EXCEPTION '% test users have been badly added', num_failed_test_users;
    END IF;
end;
$$
    language plpgsql;


DO
$$
    declare
        jid bigint;
    BEGIN

        SELECT jobid from cron.job where jobname = 'daily-test-users-cleanup' into jid;
        EXECUTE 'SELECT cron.unschedule($1)' USING jid;
    END
$$ language plpgsql;
select cron.schedule(
               'daily-test-users-cleanup',
               '30 4 * * *',
               $$ select delete_old_test_accounts() $$);