-- begin the transaction, this will allow you to rollback any changes made during the test
BEGIN;

select plan(3);

select tests.clear_authentication();

select tests.rls_enabled('public');

-- select policies_are(
--                'public',
--                'profiles',
--                ARRAY['Can only access its own profile']
--            );

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
               'SELECT concat(''"'', id::text, ''"'') FROM profiles;',
               $$VALUES((tests.get_supabase_user('authenticated_non_member_user')->'id')::text) $$,
               'Authenticated user can only access its own profile'
           );

select * from finish();

ROLLBACK;