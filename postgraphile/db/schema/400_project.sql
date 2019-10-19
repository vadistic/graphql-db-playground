-- PROJECT

-- cleanup

-- drop table if exists app_public.project cascade;
-- drop trigger if exists timestamps on app_public.project;
-- drop index if exists project_client_id_fkey_idx;

--

create table app_public.project (
    -- system
    id              uuid            primary key default uuid_generate_v1mc (),
    created_at      timestamp       not null default now(),
    updated_at      timestamp       not null default now(),

    -- scalar
    name            text            not null check (is_short_text(name)),
    description     text,

    -- refs
    client_id       uuid            constraint project_client_id_fkey
                                    references app_public.client(id)
                                    on delete set null
);

--

create index project_client_id_fkey on app_public.project(client_id);

--

comment on table app_public.project is
    e'A Project';

-- system
comment on column app_public.project.id is
    e'A projects’s id';
comment on column app_public.project.created_at is
    e'A projects’s create timestamp';
comment on column app_public.project.updated_at is
    e'A projects’s update timestamp';

-- scalar
comment on column app_public.project.name is
    e'A projects’s name';
comment on column app_public.project.description is
    e'A projects’s description';

-- refs
comment on column app_public.project.description is
    e'A projects’s description';

comment on constraint project_client_id_fkey on app_public.project is
    e'@omit manytoMany';

--

create trigger timestamps
    before insert or update
    on app_public.project
    for each row execute procedure
    app_private.tg__update_timestamps ();

--

grant select, insert, update, delete on table app_public.project to app_authenticated;