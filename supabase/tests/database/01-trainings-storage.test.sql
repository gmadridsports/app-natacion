-- begin the transaction, this will allow you to rollback any changes made during the test
BEGIN;

select plan(39);

TRUNCATE TABLE storage.objects CASCADE;
TRUNCATE TABLE storage.buckets CASCADE;
INSERT INTO storage.buckets (id, name, owner, created_at, updated_at, public, avif_autodetection, file_size_limit,
                             allowed_mime_types)
VALUES ('trainings', 'general', null, '2023-05-03 16:50:48.229805 +00:00', '2023-05-03 16:50:48.229805 +00:00', true,
        false, null, null);
INSERT INTO storage.objects (id, bucket_id, name, owner, created_at, updated_at, last_accessed_at, metadata, version)
VALUES ('843ef98f-fd33-48cb-9c08-723d9fb4ccf8', 'trainings', 'general/2023-04-17.pdf', null,
        '2023-05-03 16:51:22.235239 +00:00', '2023-05-03 16:51:30.223514 +00:00', '2023-05-03 16:51:30.194000 +00:00',
        '{
          "eTag": "\"8c0788a68ebeacf1cd925ca4285d4189\"",
          "size": 37853,
          "mimetype": "application/pdf",
          "cacheControl": "max-age=3600",
          "lastModified": "2023-05-01T23:19:35.870Z",
          "contentLength": 37853,
          "httpStatusCode": 200
        }', null);
INSERT INTO storage.objects (id, bucket_id, name, owner, created_at, updated_at, last_accessed_at, metadata, version)
VALUES ('82faf71d-57c1-44df-96d5-846553a4c448', 'trainings', 'general/2023-04-24.pdf', null,
        '2023-05-03 16:51:07.098826 +00:00', '2023-05-03 16:51:38.774943 +00:00', '2023-05-03 16:51:38.765000 +00:00',
        '{
          "eTag": "\"e429d63c15a49e826edd686bbf939358\"",
          "size": 46297,
          "mimetype": "application/pdf",
          "cacheControl": "max-age=3600",
          "lastModified": "2023-05-01T23:18:46.085Z",
          "contentLength": 46297,
          "httpStatusCode": 200
        }', null);

select policies_are(
               'storage',
               'objects',
               ARRAY ['authenticated member can download from the trainings bucket', 'everybody can download from general bucket']
           );

select policies_are(
               'storage',
               'buckets',
               ARRAY ['member can list from training bucket']
           );

create policy "authenticated member can download from the trainings bucket 2"
    on "storage"."objects"
    as permissive
    for select
    to authenticated;
;

select tests.clear_authentication();

select tests.rls_enabled('storage');
select is_empty(
               'SELECT name FROM storage.objects',
               'training files for unauth should not be returned and listed'
           );

select is_empty(
               'SELECT name FROM storage.buckets',
               'buckets for unauth should not be returned and listed'
           );

select throws_ok(
               $$ insert into storage.objects (name) values ('Post created by anon') $$,
               'new row violates row-level security policy for table "objects"'
           );

select throws_ok(
               $$ insert into storage.buckets (name) values ('Post created by anon') $$,
               'new row violates row-level security policy for table "buckets"'
           );

SELECT is_empty(
               $$ update storage.buckets set name = 'test update' returning 'this should not be returned' $$,
               'general storage cannot be updated'
           );

SELECT is_empty(
               $$ update storage.objects set name = 'test update' returning 'this should not be returned' $$,
               'general storage cannot be updated'
           );

SELECT is_empty(
               $$ update storage.buckets set name = 'test update' returning 'this should not be returned' $$,
               'general storage cannot be updated'
           );
SELECT is_empty(
               $$ update storage.objects set name = 'test update' returning 'this should not be returned' $$,
               'general storage cannot be updated'
           );

SELECT is_empty(
               $$ delete from storage.objects returning 1 $$,
               'Anon cannot delete objects'
           );

SELECT is_empty(
               $$ delete from storage.buckets returning 1 $$,
               'Anon cannot delete buckets'
           );

select results_eq(
               'select training_available_for_date(''general/2023-04-24.pdf'');',
               $$VALUES (false)$$,
               'training_available_for_date to anon should return false for a file which is available'
           );

select results_eq(
               'select training_available_for_date(''general/2023-04-31.pdf'');',
               $$VALUES (false)$$,
               'training_available_for_date to anon should return false for a file which is not available'
           );

-- authenticated USER
SELECT tests.create_supabase_user('authenticated_non_member_user', 'authenticated@gmadridnatacion.bertamini.net');
select tests.clear_authentication();
select tests.authenticate_as('authenticated_non_member_user');

select is_empty(
               'SELECT name FROM storage.objects',
               'training files for auth user should not be returned and listed'
           );

select is_empty(
               'SELECT name FROM storage.buckets',
               'buckets for auth user should not be returned and listed'
           );

select throws_ok(
               $$ insert into storage.objects (name) values ('Post created by anon') $$,
               'new row violates row-level security policy for table "objects"'
           );

select throws_ok(
               $$ insert into storage.buckets (name) values ('Post created by anon') $$,
               'new row violates row-level security policy for table "buckets"'
           );

SELECT is_empty(
               $$ update storage.buckets set name = 'test update' returning 'this should not be returned' $$,
               'general storage cannot be updated'
           );

SELECT is_empty(
               $$ update storage.objects set name = 'test update' returning 'this should not be returned' $$,
               'general storage cannot be updated'
           );

SELECT is_empty(
               $$ update storage.buckets set name = 'test update' returning 'this should not be returned' $$,
               'general storage cannot be updated'
           );
SELECT is_empty(
               $$ update storage.objects set name = 'test update' returning 'this should not be returned' $$,
               'general storage cannot be updated'
           );

SELECT is_empty(
               $$ delete from storage.objects returning 1 $$,
               'Anon cannot delete objects'
           );

SELECT is_empty(
               $$ delete from storage.buckets returning 1 $$,
               'Anon cannot delete buckets'
           );

select results_eq(
               'select training_available_for_date(''general/2023-04-24.pdf'');',
               $$VALUES (false)$$,
               'training_available_for_date to auth user should return false for a file which is available'
           );

select results_eq(
               'select training_available_for_date(''general/2023-04-31.pdf'');',
               $$VALUES (false)$$,
               'training_available_for_date to auth user should return false for a file which is not available'
           );

-- authenticated MEMBER
select tests.clear_authentication();
SELECT tests.create_supabase_user('authenticated_member_user', 'authmember@gmadridnatacion.bertamini.net');
select tests.change_supabase_user_membership('authenticated_member_user', 'member');
select tests.authenticate_as('authenticated_member_user');

select results_eq(
               'SELECT name FROM storage.objects',
               $$VALUES ('general/2023-04-17.pdf'), ('general/2023-04-24.pdf')$$,
               'training files should be returned and listed for a member user'
           );

select results_eq(
               'SELECT name FROM storage.objects',
               $$VALUES ('general/2023-04-17.pdf'), ('general/2023-04-24.pdf')$$,
               'training files should be returned and listed for a member user'
           );

select throws_ok(
               $$ insert into storage.objects (name) values ('Post created by anon') $$,
               'new row violates row-level security policy for table "objects"'
           );

select throws_ok(
               $$ insert into storage.buckets (name) values ('Post created by anon') $$,
               'new row violates row-level security policy for table "buckets"'
           );

SELECT
    is_empty(
            $$ update storage.buckets set name = 'test update' returning 'this should not be returned' $$,
            'general storage cannot be updated'
        );

SELECT
    is_empty(
            $$ update storage.objects set name = 'test update' returning 'this should not be returned' $$,
            'general storage cannot be updated'
        );

SELECT
    is_empty(
            $$ update storage.buckets set name = 'test update' returning 'this should not be returned' $$,
            'general storage cannot be updated'
        );

SELECT
    is_empty(
            $$ update storage.objects set name = 'test update' returning 'this should not be returned' $$,
            'general storage cannot be updated'
        );

SELECT
    is_empty(
            $$ delete from storage.objects returning 1 $$,
            'Anon cannot delete objects'
        );

SELECT
    is_empty(
            $$ delete from storage.buckets returning 1 $$,
            'Anon cannot delete buckets'
        );

select results_eq(
               'select training_available_for_date(''general/2023-04-24.pdf'');',
               $$VALUES (true)$$,
               'training_available_for_date should return true for a file which is available'
           );

select results_eq(
               'select training_available_for_date(''general/2023-04-31.pdf'');',
               $$VALUES (false)$$,
               'training_available_for_date should return false for a file which is not available'
           );

select * from finish();

ROLLBACK;
