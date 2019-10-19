-- AUTH

-- cleanup

-- drop function if exists app_public.authenticate cascade;
-- drop function if exists app_public.current_account cascade;
-- drop type if exists app_public.jwt_token cascade;

--
-- https://www.iana.org/assignments/jwt/jwt.xhtml

create type app_public.jwt_token as (
  sub               uuid,
  aud               text,
  iss               text,
  iat               integer,
  exp               integer,
  scopes            text[],
  name              text,
  email             text
);

--

create function app_public.authenticate(email text, password text) returns app_public.jwt_token as $$
    declare
        account app_public.account;
        full_name text;
    begin
    -- use $1 to awoid column name collision
        select a.* into account
            from app_public.account as a
            where a.email = $1;

        full_name = app_public.account_full_name(account);

        if account.password_hash = crypt($2, account.password_hash) then
        return (
            -- sub
            account.id,
            -- aud
            'postgraphile',
            -- iss
            'postgraphile',
            -- iat
            extract(epoch from now()),
            -- exp
            extract(epoch from now() + interval '1 day'),
            -- scopes
            '{"scopes"}',
            -- name
            full_name,
            -- email
            account.email
            )::app_public.jwt_token;
        else
            return null;
        end if;
    end;
$$ language plpgsql strict security definer;

comment on function app_public.authenticate (text, text) is
    e'Get JWT via email & password authentication';

grant execute on function app_public.authenticate to app_anonymous, app_authenticated;

--

create function app_private.current_account_id () returns uuid as $$
    begin
        return current_setting('jwt.claims.sub', TRUE)::uuid;
    end
$$ language plpgsql volatile;

comment on function app_private.current_account_id () is
    e'Gets the account id which was identified by JWT';


--

create function app_public.current_account () returns app_public.account as $$
    select
        *
    from
        app_public.account
    where
        id = current_setting('jwt.claims.sub', TRUE)::uuid
$$ language sql volatile;

comment on function app_public.current_account () is
    e'Gets the account who was identified by JWT';

grant execute on function app_public.current_account to app_anonymous, app_authenticated;