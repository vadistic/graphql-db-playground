-- ACCOUNT

-- DROP TABLE IF EXISTS app_public.account CASCADE;
-- DROP TABLE IF EXISTS app_private.account CASCADE;

-- DROP TRIGGER IF EXISTS timestamps ON app_public.account;
-- DROP FUNCTION IF EXISTS app_public.account_full_name;

--

CREATE TABLE app_public.account (
    -- system
    id              uuid            PRIMARY KEY DEFAULT uuid_generate_v1mc (),
    created_at      TIMESTAMP       NOT NULL DEFAULT now(),
    updated_at      TIMESTAMP       NOT NULL DEFAULT now(),

    -- scalar
    first_name      text            CHECK (is_short_text(first_name)),
    last_name       text            CHECK (is_short_text(first_name)),
    description     text
);

--

COMMENT ON TABLE app_public.account IS
    e'A account';

-- system
COMMENT ON COLUMN app_public.account.id IS
    e'An account’s id';
COMMENT ON COLUMN app_public.account.created_at IS
    e'An account’s create timestamp';
COMMENT ON COLUMN app_public.account.updated_at IS
    e'An account’s update timestamp';

-- scalar
COMMENT ON COLUMN app_public.account.first_name IS
    e'An account’s first name';
COMMENT ON COLUMN app_public.account.last_name IS
    e'An account’s last name';
COMMENT ON COLUMN app_public.account.description IS
    e'An account’s description';

--

CREATE FUNCTION app_public.account_full_name (account app_public.account)
    RETURNS text AS $$
    SELECT
        account.first_name || ' ' || account.last_name
    $$ LANGUAGE SQL STABLE;

COMMENT ON FUNCTION app_public.account_full_name (app_public.account) IS
    e'An accounts’s full name';

--

CREATE TRIGGER timestamps
    BEFORE INSERT OR UPDATE
    ON app_public.account
    FOR EACH ROW EXECUTE PROCEDURE
    app_private.tg__update_timestamps ();

--

CREATE TABLE app_private.account (
  account_id        uuid            PRIMARY KEY REFERENCES app_public.account(id) ON DELETE CASCADE,
  email             text            NOT NULL UNIQUE CHECK (email ~* '^.+@.+\..+$'),
  password_hash     text            NOT NULL,
  timezone          text            NOT NULL CHECK (is_timezone_name(timezone)) DEFAULT 'Europe/Warsaw'
);
