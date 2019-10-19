-- INIT

-- cleanup

-- drop schema if exists public cascade;
-- drop schema if exists app_public cascade;
-- drop schema if exists app_private cascade;

-- drop role if exists postgraphile;
-- drop role if exists app_anonymous;
-- drop role if exists app_authenticated;

---

create schema if not exists public;
create schema if not exists app_public;
create schema if not exists app_private;

--

create extension if not exists "uuid-ossp" with schema public;

create extension if not exists "citext" with schema public;

create extension if not exists "pgcrypto" with schema public;

create extension if not exists "pg_trgm" with schema public;


--

create role postgraphile login password 'password123';
create role app_anonymous;
create role app_authenticated;

grant app_anonymous to postgraphile;
grant app_authenticated to postgraphile;

grant usage on schema app_public to app_anonymous, app_authenticated;
