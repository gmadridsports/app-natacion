create table "public"."versions"
(
    "version"      character varying        not null,
    "published_at" timestamp with time zone not null default now(),
    "available"    boolean                  not null,
    "url"          text                     not null
);

CREATE UNIQUE INDEX versions_pkey ON public.versions USING btree (version, published_at, available);

alter table "public"."versions"
    add constraint "versions_pkey" PRIMARY KEY using index "versions_pkey";

alter table "public"."versions"
    enable row level security;

create policy "Enable select for authenticated users only"
    on "public"."versions"
    as permissive
    for select
    to authenticated
    using (true);
