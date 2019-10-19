-- PROJECT

-- cleanup

-- DROP TABLE IF EXISTS app_public.project CASCADE;
-- DROP TRIGGER IF EXISTS timestamps ON app_public.project;
-- DROP INDEX IF EXISTS project_client_id_fkey_idx;

--

CREATE TABLE app_public.project (
    -- system
    id              uuid            PRIMARY KEY DEFAULT uuid_generate_v1mc (),
    created_at      TIMESTAMP       NOT NULL DEFAULT now(),
    updated_at      TIMESTAMP       NOT NULL DEFAULT now(),

    -- scalar
    name            text            NOT NULL CHECK (is_short_text(name)),
    description     text,

    -- refs
    client_id       uuid            REFERENCES app_public.client(id)
                                    ON DELETE SET NULL
);

--

CREATE INDEX project_client_id_fkey ON app_public.project(client_id);

--

COMMENT ON TABLE app_public.project IS
    e'A Project';

-- system
COMMENT ON COLUMN app_public.project.id IS
    e'A projects’s id';
COMMENT ON COLUMN app_public.project.created_at IS
    e'A projects’s create timestamp';
COMMENT ON COLUMN app_public.project.updated_at IS
    e'A projects’s update timestamp';

-- scalar
COMMENT ON COLUMN app_public.project.name IS
    e'A projects’s name';
COMMENT ON COLUMN app_public.project.description IS
    e'A projects’s description';

-- refs
COMMENT ON COLUMN app_public.project.description IS
    e'A projects’s description';

--

CREATE TRIGGER timestamps
    BEFORE INSERT OR UPDATE
    ON app_public.project
    FOR EACH ROW EXECUTE PROCEDURE
    app_private.tg__update_timestamps ();
