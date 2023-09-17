drop policy if exists "trainings bucket only for authenticated" on "storage"."objects";
drop policy if exists "Only authenticated users can access PDFs" on "storage"."objects";
drop policy if exists "listing general bucket for authenticated" on "storage"."buckets";

create policy "authenticated member can download from the trainings bucket"
    on "storage"."objects"
    as permissive
    for select
    to authenticated
    using (bucket_id = 'trainings'::text and 'member' in (select membership_level from public.profiles where id = auth.uid()));

create policy "everybody can download from general bucket"
    on "storage"."objects"
    as permissive
    for select
    using (name = 'general');

create policy "member can list from training bucket"
    on "storage"."buckets"
    as permissive
    for select
    to authenticated
    using (name = 'trainings'::text and 'member' = (select membership_level from public.profiles where id = auth.uid()));

create
    or replace function training_available_for_date (training_path text) returns boolean
    security invoker set search_path = public
as $$
select count(id) = 1
from storage.objects
where bucket_id='trainings' and name = training_path;
$$
    language sql stable;