-- AUTH

-- cleanup

-- DROP FUNCTION IF EXISTS app_public.authenticate CASCADE;
-- DROP TYPE IF EXISTS app_public.jwt_token CASCADE;

--

CREATE TYPE app_public.jwt_token AS (
  sub               uuid,
  exp               integer,
  name              text,
  claims            text
);

--

CREATE FUNCTION app_public.authenticate(
  email text,
  password text
) RETURNS app_public.jwt_token AS $$
declare
  account app_private.account;
begin
  -- use $1 to awoid column name collision
  select a.* into account
    from app_private.account as a
    where a.email = $1;

  if account.password_hash = crypt($2, account.password_hash) then
    return (
      account.account_id,
      extract(epoch from now() + interval '1 day'),
      'todo name',
      'todo claims'
    )::app_public.jwt_token;
  else
    return null;
  end if;
end;
$$ LANGUAGE PLPGSQL STRICT SECURITY DEFINER;