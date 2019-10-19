-- TAG

-- drop table if exists app_public.tag cascade;
-- drop trigger if exists timestamps on app_public.tag;

--

create table app_public.tag (
    -- system
    id              uuid            primary key default uuid_generate_v1mc (),
    created_at      timestamp       not null default now(),
    updated_at      timestamp       not null default now(),

    -- scalar
    name            text            not null check (is_short_text(name)),
    description     text
    -- refs
);

--

comment on table app_public.tag is
    e'A tag';

-- system
comment on column app_public.tag.id is
    e'A tag’s id';
comment on column app_public.tag.created_at is
    e'A tag’s create timestamp';
comment on column app_public.tag.updated_at is
    e'A tag’s update timestamp';

-- scalar
comment on column app_public.tag.name is
    e'A tag’s name';
comment on column app_public.tag.description is
    e'A tag’s description';

--

grant select, update, delete on table app_public.tag to app_authenticated;

--

create trigger timestamps
    before insert
    or update on app_public.tag
    for each row
    execute procedure app_private.tg__update_timestamps ();

--
