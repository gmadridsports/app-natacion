-- begin the transaction, this will allow you to rollback any changes made during the test
BEGIN;

select plan(10);

select tests.clear_authentication();

select tests.rls_enabled('public');

select policies_are(
               'public',
               'profiles',
               ARRAY['authenticated users can ONLY READ their own profile']
           );

SELECT tests.create_supabase_user('authenticated_non_member_user', 'authenticated@gmadridnatacion.bertamini.net');
SELECT tests.create_supabase_user('authenticated_non_member_user_2', 'authenticated2@gmadridnatacion.bertamini.net');

select tests.clear_authentication();
select tests.authenticate_as('authenticated_non_member_user');

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
               $$VALUES((tests.get_supabase_user('authenticated_non_member_user')->'id')::text) $$,
               'Authenticated user can only access its own profile'
           );

select results_eq(
               'SELECT concat(''"'', id::text, ''"'') FROM profiles;',
               $$VALUES((tests.get_supabase_user('authenticated_non_member_user')->'id')::text) $$,
               'Authenticated user can only access its own profile'
           );

select throws_ok(
               $$ insert into public.profiles (id, membership_level) VALUES (uuid_generate_v4(), 'socio-23-24'); $$,
               'new row violates row-level security policy for table "profiles"'
           );

select is_empty(
                $$ UPDATE public.profiles SET membership_level = 'new-membership' WHERE id = auth.uid() returning 'this should not be returned' $$,
               'Authenticated user cannot update its own profile'
           );

select is_empty(
               $$ UPDATE public.profiles SET membership_level = 'new-membership' returning 'this should not be returned' $$,
               'Authenticated user cannot update other peoples profile'
           );

SELECT is_empty(
            $$ delete from public.profiles returning 1 $$,
            'cannot delete any profile'
        );

select * from finish();

ROLLBACK;