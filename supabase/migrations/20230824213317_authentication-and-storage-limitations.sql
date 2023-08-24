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

create policy "authenticated users can only read their own profile"
    on "public"."profiles"
    as permissive
    for select
    to authenticated
    using ((auth.uid() = id));
