-- This file was automatically generated from the `TUTORIAL.md` which
-- contains a complete explanation of how this schema works and why certain
-- decisions were made. If you are looking for a comprehensive tutorial,
-- definitely check it out as this file is a little tough to read.
--
-- If you want to contribute to this file, please change the
-- `TUTORIAL.md` file and then rebuild this file :)

begin;


create schema app_public;
create schema app_private;

create table app_public.person (
  id               serial primary key,
  first_name       text not null check (char_length(first_name) < 80),
  last_name        text check (char_length(last_name) < 80),
  about            text,
  created_at       timestamp default now()
);

comment on table app_public.person is 'A user of the forum.';
comment on column app_public.person.id is 'The primary unique identifier for the person.';
comment on column app_public.person.first_name is 'The person’s first name.';
comment on column app_public.person.last_name is 'The person’s last name.';
comment on column app_public.person.about is 'A short description about the user, written by the user.';
comment on column app_public.person.created_at is 'The time this person was created.';

create type app_public.post_topic as enum (
  'discussion',
  'inspiration',
  'help',
  'showcase'
);

create table app_public.post (
  id               serial primary key,
  author_id        integer not null references app_public.person(id),
  headline         text not null check (char_length(headline) < 280),
  body             text,
  topic            app_public.post_topic,
  created_at       timestamp default now()
);

comment on table app_public.post is 'A forum post written by a user.';
comment on column app_public.post.id is 'The primary key for the post.';
comment on column app_public.post.headline is 'The title written by the user.';
comment on column app_public.post.author_id is 'The id of the author user.';
comment on column app_public.post.topic is 'The topic this has been posted in.';
comment on column app_public.post.body is 'The main body text of our post.';
comment on column app_public.post.created_at is 'The time this post was created.';

alter default privileges revoke execute on functions from public;

create function app_public.person_full_name(person app_public.person) returns text as $$
  select person.first_name || ' ' || person.last_name
$$ language sql stable;

comment on function app_public.person_full_name(app_public.person) is 'A person’s full name which is a concatenation of their first and last name.';

create function app_public.post_summary(
  post app_public.post,
  length int default 50,
  omission text default '…'
) returns text as $$
  select case
    when post.body is null then null
    else substr(post.body, 0, length) || omission
  end
$$ language sql stable;

comment on function app_public.post_summary(app_public.post, int, text) is 'A truncated version of the body for summaries.';

create function app_public.person_latest_post(person app_public.person) returns app_public.post as $$
  select post.*
  from app_public.post as post
  where post.author_id = person.id
  order by created_at desc
  limit 1
$$ language sql stable;

comment on function app_public.person_latest_post(app_public.person) is 'Gets the latest post written by the person.';

create function app_public.search_posts(search text) returns setof app_public.post as $$
  select post.*
  from app_public.post as post
  where post.headline ilike ('%' || search || '%') or post.body ilike ('%' || search || '%')
$$ language sql stable;

comment on function app_public.search_posts(text) is 'Returns posts containing a given search term.';

alter table app_public.person add column updated_at timestamp default now();
alter table app_public.post add column updated_at timestamp default now();

create function app_private.set_updated_at() returns trigger as $$
begin
  new.updated_at := current_timestamp;
  return new;
end;
$$ language plpgsql;

create trigger person_updated_at before update
  on app_public.person
  for each row
  execute procedure app_private.set_updated_at();

create trigger post_updated_at before update
  on app_public.post
  for each row
  execute procedure app_private.set_updated_at();

create table app_private.person_account (
  person_id        integer primary key references app_public.person(id) on delete cascade,
  email            text not null unique check (email ~* '^.+@.+\..+$'),
  password_hash    text not null
);

comment on table app_private.person_account is 'Private information about a person’s account.';
comment on column app_private.person_account.person_id is 'The id of the person associated with this account.';
comment on column app_private.person_account.email is 'The email address of the person.';
comment on column app_private.person_account.password_hash is 'An opaque hash of the person’s password.';

create extension if not exists "pgcrypto";

create function app_public.register_person(
  first_name text,
  last_name text,
  email text,
  password text
) returns app_public.person as $$
declare
  person app_public.person;
begin
  insert into app_public.person (first_name, last_name) values
    (first_name, last_name)
    returning * into person;

  insert into app_private.person_account (person_id, email, password_hash) values
    (person.id, email, crypt(password, gen_salt('bf')));

  return person;
end;
$$ language plpgsql strict security definer;

comment on function app_public.register_person(text, text, text, text) is 'Registers a single user and creates an account in our forum.';

create role app_public_postgraphile login password 'xyz';

create role app_public_anonymous;
grant app_public_anonymous to app_public_postgraphile;

create role app_public_person;
grant app_public_person to app_public_postgraphile;

create type app_public.jwt_token as (
  role text,
  person_id integer
);

create function app_public.authenticate(
  email text,
  password text
) returns app_public.jwt_token as $$
  select ('app_public_person', person_id)::app_public.jwt_token
    from app_private.person_account
    where
      person_account.email = $1
      and person_account.password_hash = crypt($2, person_account.password_hash);
$$ language sql strict security definer;

comment on function app_public.authenticate(text, text) is 'Creates a JWT token that will securely identify a person and give them certain permissions.';

create function app_public.current_person() returns app_public.person as $$
  select *
  from app_public.person
  where id = current_setting('jwt.claims.person_id', true)::integer
$$ language sql stable;

comment on function app_public.current_person() is 'Gets the person who was identified by our JWT.';

create function app_public.change_password(current_password text, new_password text)
returns boolean as $$
declare
  current_person app_public.person;
begin
  current_person := app_public.current_person();
  if exists (select 1 from app_private.person_account where person_account.person_id = current_person.id and person_account.password_hash = crypt($1, person_account.password_hash))
  then
    update app_private.person_account set password_hash = crypt($2, gen_salt('bf')) where person_account.person_id = current_person.id;
    return true;
  else
    return false;
  end if;
end;
$$ language plpgsql strict security definer;

grant usage on schema app_public to app_public_anonymous, app_public_person;

grant select on table app_public.person to app_public_anonymous, app_public_person;
grant update, delete on table app_public.person to app_public_person;

grant select on table app_public.post to app_public_anonymous, app_public_person;
grant insert, update, delete on table app_public.post to app_public_person;
grant usage on sequence app_public.post_id_seq to app_public_person;

grant execute on function app_public.person_full_name(app_public.person) to app_public_anonymous, app_public_person;
grant execute on function app_public.post_summary(app_public.post, integer, text) to app_public_anonymous, app_public_person;
grant execute on function app_public.person_latest_post(app_public.person) to app_public_anonymous, app_public_person;
grant execute on function app_public.search_posts(text) to app_public_anonymous, app_public_person;
grant execute on function app_public.authenticate(text, text) to app_public_anonymous, app_public_person;
grant execute on function app_public.current_person() to app_public_anonymous, app_public_person;
grant execute on function app_public.change_password(text, text) to app_public_person;

grant execute on function app_public.register_person(text, text, text, text) to app_public_anonymous;

alter table app_public.person enable row level security;
alter table app_public.post enable row level security;

create policy select_person on app_public.person for select
  using (true);

create policy select_post on app_public.post for select
  using (true);

create policy update_person on app_public.person for update to app_public_person
  using (id = current_setting('jwt.claims.person_id', true)::integer);

create policy delete_person on app_public.person for delete to app_public_person
  using (id = current_setting('jwt.claims.person_id', true)::integer);

create policy insert_post on app_public.post for insert to app_public_person
  with check (author_id = current_setting('jwt.claims.person_id', true)::integer);

create policy update_post on app_public.post for update to app_public_person
  using (author_id = current_setting('jwt.claims.person_id', true)::integer);

create policy delete_post on app_public.post for delete to app_public_person
  using (author_id = current_setting('jwt.claims.person_id', true)::integer);


commit;
