-- WORKSPACE

-- DROP TABLE IF EXISTS app_public.workspace CASCADE;
-- DROP TRIGGER IF EXISTS timestamps ON app_public.workspace;
-- DROP FUNCTION IF EXISTS app_public.workspace;

--

CREATE TABLE app_public.workspace (
    -- system
    id              uuid        PRIMARY KEY DEFAULT uuid_generate_v1mc (),
    created_at      TIMESTAMP   NOT NULL DEFAULT now(),
    updated_at      TIMESTAMP   NOT NULL DEFAULT now(),
    -- scalar
    name            text        NOT NULL,
    description     text
    -- refs
);

--

COMMENT ON TABLE app_public.workspace IS
    e'A workspace';

COMMENT ON COLUMN app_public.workspace.id IS
    e'An workspace’s id';
COMMENT ON COLUMN app_public.workspace.created_at IS
    e'An workspace’s create timestamp';
COMMENT ON COLUMN app_public.workspace.updated_at IS
    e'An workspace’s update timestamp';

COMMENT ON COLUMN app_public.workspace.name IS
    e'An workspace’s name';
COMMENT ON COLUMN app_public.workspace.description IS
    e'An workspace’s description';

--


CREATE TRIGGER timestamps
    BEFORE INSERT OR UPDATE
    ON app_public.workspace
    FOR EACH ROW EXECUTE PROCEDURE
    app_private.tg__update_timestamps ();

--

