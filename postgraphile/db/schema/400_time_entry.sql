-- TIME_ENTRY

-- cleanup

-- drop table if exists app_public.time_entry cascade;
-- drop trigger if exists timestamps on app_public.time_entry;

--

create table app_public.time_entry (
    -- system
    id              uuid            primary key default uuid_generate_v1mc (),
    created_at      timestamp       not null default now(),
    updated_at      timestamp       not null default now(),

    -- scalar
    name            text            check (is_medium_text(name)),
    description     text,
    started_at      timestamp,
    ended_at        timestamp,

    -- refs
    account_id      uuid            not null
                                    constraint time_entry_account_id_fkey
                                    references app_public.account
                                    on delete set null,

    project_id      uuid            constraint time_entry_project_id_fkey
                                    references app_public.project
                                    on delete set null,

    client_id       uuid            constraint time_entry_client_id_fkey
                                    references app_public.client
                                    on delete set null
);

--

create index time_entry_account_id_idx on app_public.time_entry(account_id);
create index time_entry_project_id_idx on app_public.time_entry(project_id);
create index time_entry_client_id_idx on app_public.time_entry(client_id);

--

comment on table app_public.time_entry is
    e'A time entry';

-- system
comment on column app_public.time_entry.id is
    e'A time entry’s id';
comment on column app_public.time_entry.created_at is
    e'A time entry’s create timestamp';
comment on column app_public.time_entry.updated_at is
    e'A time entry’s update timestamp';

-- scalar
comment on column app_public.time_entry.name is
    e'A time entry’s name';
comment on column app_public.time_entry.description is
    e'A time entry’s description';
comment on column app_public.time_entry.started_at is
    e'A time entry’s start timestamp';
comment on column app_public.time_entry.ended_at is
    e'A time entry’s end timestamp';

-- refs
comment on column app_public.time_entry.account_id is
    e'A time entry’s author reference';
comment on column app_public.time_entry.project_id is
    e'A time entry’s project reference';
comment on column app_public.time_entry.client_id is
    e'A time entry’s client reference';

comment on constraint time_entry_account_id_fkey on app_public.time_entry is
    e'@omit manyToMany';
comment on constraint time_entry_project_id_fkey on app_public.time_entry is
    e'@omit manyToMany';
comment on constraint time_entry_client_id_fkey on app_public.time_entry is
    e'@omit manyToMany';

--

grant select, insert, update, delete on table app_public.time_entry to app_authenticated;

--

create trigger timestamps
    before insert or update
    on app_public.time_entry
    for each row execute procedure
    app_private.tg__update_timestamps ();

--
