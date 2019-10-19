-- ACCOUNT

-- drop table if exists app_public.account cascade;
-- drop table if exists app_private.account cascade;

-- drop trigger if exists timestamps on app_public.account;
-- drop function if exists app_public.account_full_name;

--

create table app_public.account (
    -- system
    id              uuid            primary key default uuid_generate_v1mc (),
    created_at      timestamp       not null default now(),
    updated_at      timestamp       not null default now(),

    -- scalar
    first_name      text            check (is_short_text(first_name)),
    last_name       text            check (is_short_text(first_name)),
    description     text,
    email           text            not null unique check (email ~* '^.+@.+\..+$'),
    timezone        text            not null check (is_timezone_name(timezone)) default 'Europe/Warsaw'
);

--

comment on table app_public.account is
    e'@omit all,create,update,delete\nA account';

-- system
comment on column app_public.account.id is
    e'An account’s id';
comment on column app_public.account.created_at is
    e'An account’s create timestamp';
comment on column app_public.account.updated_at is
    e'An account’s update timestamp';

-- scalar
comment on column app_public.account.first_name is
    e'An account’s first name';
comment on column app_public.account.last_name is
    e'An account’s last name';
comment on column app_public.account.description is
    e'An account’s description';

--

grant select, update on table app_public.account to app_authenticated;

--

create function app_public.account_full_name (account app_public.account)
    returns text as $$
    select account.first_name || ' ' || account.last_name
$$ language sql stable;

comment on function app_public.account_full_name (app_public.account) is
    e'An accounts’s full name';

grant execute on function app_public.account_full_name to app_authenticated;

--

create trigger timestamps
    before insert or update
    on app_public.account
    for each row execute procedure
    app_private.tg__update_timestamps ();

--

create table app_private.account (
  account_id        uuid            primary key references app_public.account(id) on delete cascade,
  password_hash     text            not null
);

--
