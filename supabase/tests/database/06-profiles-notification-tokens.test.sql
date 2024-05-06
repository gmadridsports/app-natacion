-- begin the transaction, this will allow you to rollback any changes made during the test
BEGIN;

--- given the number of tests that will be run
select plan(5);

--
-- 1. If a notification token is added for a user, their own preferences are copied from their profile
--
-- given a new created authenticated member user
UPDATE public.profiles SET notification_preferences = '{"other": false,"training-week": false,"bulletin-board": false}'::jsonb;
SELECT tests.create_supabase_user('t1_member_user', 't1-member@gmadridnatacion.bertamini.net');

-- given a specific notification preferences for the user
select results_eq($$ SELECT notification_preferences FROM profiles WHERE id= (tests.get_supabase_user('t1_member_user') ->> 'id')::uuid$$, $$VALUES('{"other": true, "training-week": true, "bulletin-board": true}'::jsonb)$$);
UPDATE public.profiles SET notification_preferences = '{"other": true,"training-week": true,"bulletin-board": false}' WHERE id = (tests.get_supabase_user('t1_member_user') ->> 'id')::uuid;
select results_eq($$ SELECT notification_preferences FROM profiles WHERE id= (tests.get_supabase_user('t1_member_user') ->> 'id')::uuid$$, $$VALUES('{"other": true, "training-week": true, "bulletin-board": false}'::jsonb)$$);

-- when I add a new notification token for the user
insert into auth.sessions(id, user_id)
VALUES ('1d36c5da-e78e-42b7-aeb2-212b161918b6'::uuid,
        (tests.get_supabase_user('t1_member_user') ->> 'id')::uuid);
INSERT INTO public.notification_tokens (user_id, session_id, token)
VALUES ((tests.get_supabase_user('t1_member_user') ->> 'id')::uuid,
        '1d36c5da-e78e-42b7-aeb2-212b161918b6'::uuid, 'notification-token-1');

-- then their preferences are the latest ones from profile for the user
select results_eq($$ SELECT preferences FROM notification_tokens WHERE token = 'notification-token-1'$$, $$VALUES('{"other": true,"training-week": true,"bulletin-board": false}'::jsonb)$$);

--
-- 3. If a preference is edited on the preferences, all the user's tokens will have the new preference updated
--
-- given a new created authenticated generic user
UPDATE public.profiles SET notification_preferences = '{"other": false,"training-week": false,"bulletin-board": false}'::jsonb;
SELECT tests.create_supabase_user('t2_user', 't2-user@gmadridnatacion.bertamini.net');

-- given a specific notification preferences for the user
select results_eq($$ SELECT notification_preferences FROM profiles WHERE id= (tests.get_supabase_user('t2_user') ->> 'id')::uuid$$, $$VALUES('{"other": true, "training-week": true, "bulletin-board": true}'::jsonb)$$);

-- when the user changes the notification preferences on the profile
UPDATE public.profiles SET notification_preferences = '{"other": true,"training-week": true,"bulletin-board": false}' WHERE id = (tests.get_supabase_user('t2_user') ->> 'id')::uuid;

-- then I have it the notification tokens updated
select results_eq($$ SELECT notification_preferences FROM profiles WHERE id= (tests.get_supabase_user('t2_user') ->> 'id')::uuid$$, $$VALUES('{"other": true, "training-week": true, "bulletin-board": false}'::jsonb)$$);

select * from finish();
ROLLBACK;
