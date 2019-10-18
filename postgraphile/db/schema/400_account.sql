CREATE TABLE app_public.account (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v1mc (),
    created_at timestamp DEFAULT now(),
    updated_at timestamp DEFAULT now(),
    --
    email text NOT NULL UNIQUE,
    first_name text NOT NULL CHECK (char_length(first_name) < 80),
    last_name text CHECK (char_length(last_name) < 80),
    description text
);

--
COMMENT ON TABLE app_public.account IS E'A account';

COMMENT ON COLUMN app_public.account.id IS E'A account’s id';

COMMENT ON COLUMN app_public.account.created_at IS E'A account’s create timestamp';

COMMENT ON COLUMN app_public.account.updated_at IS E'A account’s update timestamp';

COMMENT ON COLUMN app_public.account.email IS E'A account’s email';

COMMENT ON COLUMN app_public.account.first_name IS E'A account’s first name';

COMMENT ON COLUMN app_public.account.last_name IS E'A account’s last name';

COMMENT ON COLUMN app_public.account.description IS E'A account’s description';

--
CREATE TRIGGER timestamps
    BEFORE INSERT
    OR UPDATE ON app_public.account
    FOR EACH ROW
    EXECUTE PROCEDURE app_private.tg__update_timestamps ();

--
CREATE FUNCTION app_public.account_full_name (account app_public.account)
    RETURNS text
    AS $$
    SELECT
        account.first_name || ' ' || account.last_name
$$
LANGUAGE sql
STABLE;

COMMENT ON FUNCTION app_public.account_full_name (app_public.account) IS E'A accounts’s full name';

