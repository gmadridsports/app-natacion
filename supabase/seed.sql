INSERT INTO storage.buckets (id, name, owner, created_at, updated_at, public, avif_autodetection, file_size_limit, allowed_mime_types) VALUES ('trainings', 'trainings', null, '2023-05-03 16:50:48.229805 +00:00', '2023-05-03 16:50:48.229805 +00:00', false, false, null, null);
-- INSERT INTO storage.objects (id, bucket_id, name, owner, created_at, updated_at, last_accessed_at, metadata, version) VALUES ('843ef98f-fd33-48cb-9c08-723d9fb4ccf8', 'trainings', 'weekly_trainings/2023-04-17.pdf', null, '2023-05-03 16:51:22.235239 +00:00', '2023-05-03 16:51:30.223514 +00:00', '2023-05-03 16:51:30.194000 +00:00', '{"eTag": "\"8c0788a68ebeacf1cd925ca4285d4189\"", "size": 37853, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2023-05-01T23:19:35.870Z", "contentLength": 37853, "httpStatusCode": 200}', null);
-- INSERT INTO storage.objects (id, bucket_id, name, owner, created_at, updated_at, last_accessed_at, metadata, version) VALUES ('82faf71d-57c1-44df-96d5-846553a4c448', 'trainings', 'weekly_trainings/2023-04-24.pdf', null, '2023-05-03 16:51:07.098826 +00:00', '2023-05-03 16:51:38.774943 +00:00', '2023-05-03 16:51:38.765000 +00:00', '{"eTag": "\"e429d63c15a49e826edd686bbf939358\"", "size": 46297, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2023-05-01T23:18:46.085Z", "contentLength": 46297, "httpStatusCode": 200}', null);
--
-- TEST FRAMEWORK
--
create extension if not exists pg_cron with schema extensions;
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


--
-- END TEST FRAMEWORK
--

