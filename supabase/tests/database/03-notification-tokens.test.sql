-- begin the transaction, this will allow you to rollback any changes made during the test
BEGIN;

select plan(13);

-- first user with a session and notification token associated
SELECT tests.create_supabase_user('authenticated_non_member_user', 'authenticated@gmadridnatacion.bertamini.net');
insert into auth.sessions(id, user_id)
VALUES ('1d36c5da-e78e-42b7-aeb2-212b161918b1'::uuid,
        (tests.get_supabase_user('authenticated_non_member_user') ->> 'id')::uuid);
INSERT INTO public.notification_tokens (user_id, session_id, token)
VALUES ((tests.get_supabase_user('authenticated_non_member_user') ->> 'id')::uuid,
        '1d36c5da-e78e-42b7-aeb2-212b161918b1'::uuid, 'a-notification-token');

-- user without a notification token associated
SELECT tests.create_supabase_user('authenticated_non_member_user_no_token',
                                  'authenticated+no+token@gmadridnatacion.bertamini.net');
insert into auth.sessions(id, user_id)
VALUES ('1d36c5da-e78e-42b7-aeb2-212b161918b2'::uuid,
        (tests.get_supabase_user('authenticated_non_member_user_no_token') ->> 'id')::uuid);


SELECT tests.create_supabase_user('authenticated_member_user', 'authenticated+member@gmadridnatacion.bertamini.net');
insert into auth.sessions(id, user_id)
VALUES ('46aa6ef4-86d6-485e-ad36-4f1ddb0dff94'::uuid,
        (tests.get_supabase_user('authenticated_member_user') ->> 'id')::uuid);
INSERT INTO public.notification_tokens (user_id, session_id, token)
VALUES ((tests.get_supabase_user('authenticated_member_user') ->> 'id')::uuid,
        '46aa6ef4-86d6-485e-ad36-4f1ddb0dff94'::uuid, 'another-notification-token');

select tests.clear_authentication();

select tests.rls_enabled('public');

select policies_are(
               'public',
               'notification_tokens',
               ARRAY ['notification_tokens_policy', 'notification_tokens_update_policy', 'notification_tokens_insert_policy']
           );

select results_eq(
               'SELECT count(*) FROM notification_tokens',
               $$VALUES(0::bigint) $$,
               'Anon user returns nothing'
           );

select tests.authenticate_as('authenticated_non_member_user_no_token');
select results_eq(
               'SELECT count(*) FROM notification_tokens',
               $$VALUES(0::bigint) $$,
               'Authenticated user gets its own session token'
           );

SELECT lives_ok(
               $$INSERT INTO public.notification_tokens VALUES (((tests.get_supabase_user('authenticated_non_member_user_no_token')->>'id')::uuid), '1d36c5da-e78e-42b7-aeb2-212b161918b2'::uuid, 'a-token-insertion') RETURNING * $$,
               $$can insert its own notification token$$
           );

select results_eq(
               'SELECT count(*) FROM notification_tokens',
               $$VALUES(1::bigint) $$,
               'Authenticated user gets its own session token'
           );

SELECT throws_ok(
               $$INSERT INTO public.notification_tokens VALUES (((tests.get_supabase_user('authenticated_non_member_user')->>'id')::uuid), '1d36c5da-e78e-42b7-aeb2-212b161918b1'::uuid, 'a-token-insertion') RETURNING * $$,
               $$new row violates row-level security policy for table "notification_tokens"$$
           );

select results_eq(
                $$ UPDATE public.notification_tokens SET token = 'new-token-updated' WHERE user_id = auth.uid() AND session_id = '1d36c5da-e78e-42b7-aeb2-212b161918b2' returning 'this should be returned' $$,
               $$VALUES('this should be returned'::text)$$,
    'user can update its own notification token'
           );

select is_empty(
               $$ UPDATE public.notification_tokens SET token = 'new-token-updated' WHERE user_id = (tests.get_supabase_user('authenticated_non_member_user') ->> 'id')::uuid AND session_id = '1d36c5da-e78e-42b7-aeb2-212b161918b1' returning 'this should be returned' $$,
               $$cannot update other users' tokens$$
           );

SELECT is_empty(
            $$ delete from public.notification_tokens where user_id = auth.uid() returning 1 $$,
            'cannot delete its own token'
        );

SELECT is_empty(
               $$ delete from public.notification_tokens returning 1 $$,
               'cannot delete any token'
           );

select tests.clear_authentication();

SELECT function_privs_are('public', 'enable_membership', ARRAY['text'], 'dashboard_user', ARRAY['EXECUTE'], 'enable_membership only for privileged user');
SELECT function_privs_are('public', 'enable_membership', ARRAY['text'], 'anon', ARRAY[]::text[], 'non privileged roles cannot execute enable_membership');

