-- begin the transaction, this will allow you to rollback any changes made during the test
BEGIN;

select plan(10);

-- generic user that can authenticate (irrespective of membership status)
SELECT tests.create_supabase_user('authenticated_non_member_user', 'authenticated@gmadridnatacion.bertamini.net');

select tests.clear_authentication();

select tests.rls_enabled('public');

select policies_are(
               'public',
               'versions',
               ARRAY ['Enable select for authenticated users only']
           );

select is_empty(
               $$ SELECT * from public.versions; $$,
               $$Unauthenticated users cannot read versions$$
           );
SELECT throws_ok(
               $$INSERT INTO public.versions(available, version, published_at, url) values (true, '2.0.0+3', now(), 'http://gmadridnatacion.bertamini.net/update?downloadUrl=https%3A%2F%2Fwww.icloud.com%2Ficlouddrive%2F075SDYCiD7qX4BhFMubxRsSgg%23gmadrid-app-release') RETURNING * $$,
               $$new row violates row-level security policy for table "versions"$$
           );
select is_empty(
               $$ UPDATE public.versions SET version = 'new-version-updated' WHERE available = TRUE returning 'this should be returned' $$,
               $$cannot update versions$$
           );

SELECT is_empty( $$ delete from public.versions where available = true returning 1 $$,
            'cannot delete versions'
        );

select tests.authenticate_as('authenticated_non_member_user');
select results_eq(
               'SELECT version FROM versions ORDER BY published_at DESC LIMIT 1',
               $$VALUES('2.0.0+3'::varchar) $$,
               'Authenticated user can read the versions available'
           );

SELECT throws_ok(
               $$INSERT INTO public.versions(available, version, published_at, url) values (true, '2.0.0+3', now(), 'http://gmadridnatacion.bertamini.net/update?downloadUrl=https%3A%2F%2Fwww.icloud.com%2Ficlouddrive%2F075SDYCiD7qX4BhFMubxRsSgg%23gmadrid-app-release') RETURNING * $$,
               $$new row violates row-level security policy for table "versions"$$
           );

select is_empty(
               $$ UPDATE public.versions SET version = 'new-version-updated' WHERE available = TRUE returning 'this should be returned' $$,
               $$cannot update versions$$
           );

SELECT is_empty( $$ delete from public.versions where available = true returning 1 $$,
                 'cannot delete versions'
           );

select * from finish();
ROLLBACK;