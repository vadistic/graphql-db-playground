-- CLIENT

-- DROP TABLE IF EXISTS app_public.client CASCADE;
-- DROP TRIGGER IF EXISTS timestamps ON app_public.client;

--

CREATE TABLE app_public.client (
    -- system
    id              uuid            PRIMARY KEY DEFAULT uuid_generate_v1mc (),
    created_at      TIMESTAMP       NOT NULL DEFAULT now(),
    updated_at      TIMESTAMP       NOT NULL DEFAULT now(),
    -- scalar
    name            text            NOT NULL CHECK (is_short_text(name)),
    description     text
    -- refs
);

--

COMMENT ON TABLE app_public.client IS
    e'A client';

-- system
COMMENT ON COLUMN app_public.client.id IS
    e'A client’s id';
COMMENT ON COLUMN app_public.client.created_at IS
    e'A client’s create timestamp';
COMMENT ON COLUMN app_public.client.updated_at IS
    e'A client’s update timestamp';

-- scalar
COMMENT ON COLUMN app_public.client.name IS
    e'A client’s name';
COMMENT ON COLUMN app_public.client.description IS
    e'A client’s description';

--

CREATE TRIGGER timestamps
    BEFORE INSERT OR UPDATE
    ON app_public.client
    FOR EACH ROW EXECUTE PROCEDURE
    app_private.tg__update_timestamps ();

--