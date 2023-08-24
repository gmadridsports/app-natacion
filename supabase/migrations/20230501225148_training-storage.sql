create policy "Enable listing general bucket for all users"
on "storage"."buckets"
as permissive
for select
               to public
               using ((name = 'general'::text));

create policy "Everybody can access PDFs"
on "storage"."objects"
as permissive
for select
               to public
               using (((bucket_id = 'general'::text) AND (storage.extension(name) = 'pdf'::text)));

INSERT INTO storage.buckets (id, name, owner, created_at, updated_at, public, avif_autodetection, file_size_limit, allowed_mime_types) VALUES ('general', 'general', null, '2023-05-03 16:50:48.229805 +00:00', '2023-05-03 16:50:48.229805 +00:00', true, false, null, null) ON CONFLICT DO NOTHING;