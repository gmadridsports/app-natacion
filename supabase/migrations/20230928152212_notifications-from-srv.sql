create table
    public.notification_tokens
(
    user_id    uuid not null,
    session_id uuid not null,
    token      text null,
    constraint notification_tokens_pkey primary key (user_id, session_id),
    constraint profiles_id_fkey foreign key (user_id) references auth.users (id) on delete cascade,
    constraint sessions_id_fkey foreign key (session_id) references auth.sessions (id) on delete cascade
) tablespace pg_default;

create policy notification_tokens_policy on public.notification_tokens for select using (user_id = auth.uid());
create policy notification_tokens_update_policy on public.notification_tokens for update using (user_id = auth.uid());
create policy notification_tokens_insert_policy on public.notification_tokens for insert with check (user_id = auth.uid());

alter table "public"."notification_tokens"
    enable row level security;

create or replace function enable_membership(email_updating_user text)
    returns table(notification_token text)
    language plpgsql
    -- needed because we touch auth.users
    security definer
as $$
declare
    updating_user_id uuid;
begin
    select id from auth.users where email=$1 into updating_user_id;
    update public.profiles set membership_level='member' where id = updating_user_id;

    return query(select token from public.notification_tokens where user_id = updating_user_id);
end;
$$;

revoke execute on function enable_membership from public;
GRANT EXECUTE ON FUNCTION enable_membership(email_updating_user text) TO service_role;
GRANT EXECUTE ON FUNCTION enable_membership(email_updating_user text) TO dashboard_user;
