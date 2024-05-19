-- begin the transaction, this will allow you to rollback any changes made during the test
BEGIN;

--- given the number of tests that will be run
select plan(22);

select tests.clear_authentication();

--
-- 0. Policies are
--
select tests.rls_enabled('public');
select policies_are(
               'public',
               'profiles',
               ARRAY['authenticated users can READ their own profile', 'authenticated users can UPDATE their own profile']
           );

--
-- 1. Authenticated non-member user can perform only reading operations of their own profiles
--
-- given two generic non-member users that can authenticate
SELECT tests.create_supabase_user('1_authenticated_non_member_user', 'authenticated@gmadridnatacion.bertamini.net');
SELECT tests.create_supabase_user('1_authenticated_non_member_user_2', 'authenticated2@gmadridnatacion.bertamini.net');

-- When I authenticate as a non-member user
select tests.clear_authentication();
select tests.authenticate_as('1_authenticated_non_member_user');

-- Then I can only read my own profile
select results_eq(
               'SELECT count(id) FROM profiles',
               $$VALUES(1::bigint) $$,
               'Authenticated user returns its own profile only'
           );

select results_eq(
               'SELECT membership_level FROM profiles',
               $$VALUES('user'::text) $$,
               'New user has membership_level = user'
           );

select results_eq(
               'SELECT concat(''"'', id::text, ''"'') FROM profiles;',
               $$VALUES((tests.get_supabase_user('1_authenticated_non_member_user')->'id')::text) $$,
               'Authenticated user can only access its own profile'
           );

-- Then I cannot add new rows
select throws_ok(
               $$ insert into public.profiles (id, membership_level) VALUES (uuid_generate_v4(), 'socio-23-24'); $$,
               'permission denied for table profiles'
           );

-- Then I cannot update my membership
select throws_ok(
                $$ UPDATE public.profiles SET membership_level = 'new-membership' WHERE id = auth.uid() returning 'this should not be returned' $$,
               'permission denied for table profiles'
           );

-- Then I cannot change my notification preferences
select throws_ok(
               $$ UPDATE public.profiles SET notification_preferences = '{"other": false,"training-week": true,"bulletin-board": true}' WHERE id = auth.uid() returning 'this should not be returned' $$,
               'You cannot change these values by yourself.'
       );

-- Then I cannot change my id
select throws_ok(
               $$ UPDATE public.profiles SET id = auth.uid() WHERE id = auth.uid() returning 'this should not be returned' $$,
               'permission denied for table profiles'
       );

-- Then I cannot change other's people id
select throws_ok(
               $$ UPDATE public.profiles SET id = auth.uid() WHERE id = (tests.get_supabase_user('1_authenticated_non_member_user') ->> 'id')::uuid $$,
               'permission denied for table profiles'
       );

SELECT is_empty(
            $$ delete from public.profiles returning 1 $$,
            'cannot delete any profile'
        );

select tests.clear_authentication();

--
-- 2. Authenticated member user can only change their own notification preferences
--
-- given two authenticated users, one member and the other a generic one
select tests.rls_enabled('public');
select tests.create_supabase_user('t2_member_user', 't2-member@gmadridnatacion.bertamini.net');
select tests.change_supabase_user_membership('t2_member_user', 'member');

select tests.create_supabase_user('t2_authenticated_non_member_user', 't2-authenticated@gmadridnatacion.bertamini.net');

-- when I authenticate as a member user
select tests.authenticate_as('t2_member_user');

-- Then I can only read my own profile
select results_eq(
               'SELECT count(id) FROM profiles',
               $$VALUES(1::bigint) $$,
               'Authenticated user returns its own profile only'
       );

select results_eq(
               'SELECT membership_level FROM profiles',
               $$VALUES('member'::text) $$,
               'New user has membership_level = member'
       );

select results_eq(
               'SELECT concat(''"'', id::text, ''"'') FROM profiles;',
               $$VALUES((tests.get_supabase_user('t2_member_user')->'id')::text) $$,
               'Authenticated user can only access its own profile'
       );

-- Then I cannot add new rows
select throws_ok(
               $$ insert into public.profiles (id, membership_level) VALUES (uuid_generate_v4(), 'socio-23-24'); $$,
               'permission denied for table profiles'
           );

-- Then I cannot update my membership
select throws_ok(
               $$ UPDATE public.profiles SET membership_level = 'new-membership' WHERE id = auth.uid() returning 'this should not be returned' $$,
               'permission denied for table profiles'
       );

-- Then I can change my own notification preferences
select results_eq(
               $$ UPDATE public.profiles SET notification_preferences = '{"other": false,"training-week": true,"bulletin-board": true}' WHERE id = auth.uid() returning 1$$,
               $$VALUES(1) $$,
               'Member user can edit their preferences'
       );

-- Then I cannot change my id
select throws_ok(
               $$ UPDATE public.profiles SET id = auth.uid() WHERE id = auth.uid() returning 'this should not be returned' $$,
               'permission denied for table profiles'
       );

-- Then I cannot change other people's preferences
select is_empty(
               $$ UPDATE public.profiles SET notification_preferences = '{"other": false,"training-week": true,"bulletin-board": true}' WHERE id =(tests.get_supabase_user('t2_authenticated_non_member_user') ->> 'id')::uuid returning 1$$,
               'You cannot change these values by yourself.'
       );

-- Then I cannot change other's people id
select throws_ok(
               $$ UPDATE public.profiles SET id = auth.uid() WHERE id = (tests.get_supabase_user('t2_authenticated_non_member_user') ->> 'id')::uuid $$,
               'permission denied for table profiles'
       );

-- Then I cannot delete anything
SELECT is_empty(
               $$ delete from public.profiles returning 1 $$,
               'cannot delete any profile'
       );

select tests.clear_authentication();

--
-- After all
--
select * from finish();

ROLLBACK;
