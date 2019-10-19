-- CLIENT

-- drop table if exists app_public.client cascade;
-- drop trigger if exists timestamps on app_public.client;

--

create table app_public.client (
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

comment on table app_public.client is
    e'A client';

-- system
comment on column app_public.client.id is
    e'A client’s id';
comment on column app_public.client.created_at is
    e'A client’s create timestamp';
comment on column app_public.client.updated_at is
    e'A client’s update timestamp';

-- scalar
comment on column app_public.client.name is
    e'A client’s name';
comment on column app_public.client.description is
    e'A client’s description';

--

grant select, insert, update, delete on table app_public.client to app_authenticated;

--

create trigger timestamps
    before insert or update
    on app_public.client
    for each row execute procedure
    app_private.tg__update_timestamps ();

--
