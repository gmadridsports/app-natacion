drop table if exists "public"."profiles" cascade;
create table "public"."profiles"
(
    "id"               uuid not null,
    "membership_level" text
);

alter table "public"."profiles"
    enable row level security;

CREATE UNIQUE INDEX profiles_pkey ON public.profiles USING btree (id);

alter table "public"."profiles" add constraint "profiles_pkey" PRIMARY KEY using index "profiles_pkey";

alter table "public"."profiles" add constraint "profiles_id_fkey" FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."profiles" validate constraint "profiles_id_fkey";

CREATE OR REPLACE FUNCTION public.handle_new_user()
    RETURNS trigger
    LANGUAGE plpgsql
    SECURITY DEFINER
    SET search_path TO 'public'
AS $function$
begin
    insert into public.profiles (id, membership_level)
    values (new.id, 'user');
    return new;
end;
$function$;

create trigger on_auth_user_created
    after insert on auth.users
    for each row execute procedure public.handle_new_user();

create policy "authenticated users can ONLY READ their own profile"
    on "public"."profiles"
    as permissive
    for select
    to authenticated
    using ((auth.uid() = id));

-- removing old policies
drop policy IF EXISTS "Enable listing general bucket for all users" on "storage"."buckets";
drop policy IF EXISTS "Everybody can access PDFs" on "storage"."objects";

-- adding new bucket policies
create policy "trainings bucket only for authenticated"
    on "storage"."objects"
    as permissive
    for select
    to authenticated
    using (bucket_id = 'trainings'::text);

create policy "Only authenticated users can access PDFs"
    on "storage"."objects"
    as permissive
    for select
    to authenticated
    using ((bucket_id = 'general'::text) AND (storage.extension(name) = 'pdf'::text));

create policy "listing general bucket for authenticated"
    on "storage"."buckets"
    as permissive
    for select
    to authenticated
    using ((name = 'general'::text));
