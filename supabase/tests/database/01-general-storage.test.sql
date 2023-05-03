-- begin the transaction, this will allow you to rollback any changes made during the test
BEGIN;

select plan(12);

TRUNCATE TABLE storage.objects CASCADE ;
TRUNCATE TABLE storage.buckets CASCADE;
INSERT INTO storage.buckets (id, name, owner, created_at, updated_at, public, avif_autodetection, file_size_limit, allowed_mime_types) VALUES ('general', 'general', null, '2023-05-03 16:50:48.229805 +00:00', '2023-05-03 16:50:48.229805 +00:00', true, false, null, null);
INSERT INTO storage.objects (id, bucket_id, name, owner, created_at, updated_at, last_accessed_at, metadata, version) VALUES ('843ef98f-fd33-48cb-9c08-723d9fb4ccf8', 'general', 'trainings/2023-04-17.pdf', null, '2023-05-03 16:51:22.235239 +00:00', '2023-05-03 16:51:30.223514 +00:00', '2023-05-03 16:51:30.194000 +00:00', '{"eTag": "\"8c0788a68ebeacf1cd925ca4285d4189\"", "size": 37853, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2023-05-01T23:19:35.870Z", "contentLength": 37853, "httpStatusCode": 200}', null);
INSERT INTO storage.objects (id, bucket_id, name, owner, created_at, updated_at, last_accessed_at, metadata, version) VALUES ('82faf71d-57c1-44df-96d5-846553a4c448', 'general', 'trainings/2023-04-24.pdf', null, '2023-05-03 16:51:07.098826 +00:00', '2023-05-03 16:51:38.774943 +00:00', '2023-05-03 16:51:38.765000 +00:00', '{"eTag": "\"e429d63c15a49e826edd686bbf939358\"", "size": 46297, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2023-05-01T23:18:46.085Z", "contentLength": 46297, "httpStatusCode": 200}', null);


select policies_are(
                'storage',
                'buckets',
                ARRAY['Enable listing general bucket for all users']
            );

 select policies_are(
                'storage',
                'objects',
                ARRAY['Everybody can access PDFs']
            );


select tests.clear_authentication();

select tests.rls_enabled('storage');

select results_eq(
               'SELECT name FROM storage.objects',
               $$VALUES ('trainings/2023-04-17.pdf'), ('trainings/2023-04-24.pdf')$$,
               'training files should be returned and listed'
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

select * from finish();

ROLLBACK;
