create table
    public.bulletin_board
(
    id                        uuid                        not null,
    publication_date          timestamp without time zone not null,
    is_published              boolean                     not null,
    source_id                 text                        not null,
    origin_source             text                        not null,
    body_message              text                        not null,
    original_raw_data_message jsonb                       not null,
    changes                   jsonb[]                     null,
    constraint bulletin_board_pkey primary key (id),
    constraint bulletin_board_origin_source_source_id_key unique (origin_source, source_id)
) tablespace pg_default;

alter table "public"."bulletin_board"
    enable row level security;

create policy "authenticated member can read bulletin_board"
    on "public"."bulletin_board"
    as permissive
    for select
    to authenticated
    using ('member' in (select membership_level
                        from public.profiles
                        where id = auth.uid()));

CREATE INDEX "bulletin_board_member_idx"
    ON "public"."bulletin_board" USING btree
        (is_published, publication_date, id)
    WHERE is_published = true;

alter publication supabase_realtime add table "public"."bulletin_board";
