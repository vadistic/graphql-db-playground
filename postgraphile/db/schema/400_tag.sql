-- TAG

-- DROP TABLE IF EXISTS app_public.tag CASCADE;
-- DROP TRIGGER IF EXISTS timestamps ON app_public.tag;

--

CREATE TABLE app_public.tag (
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

COMMENT ON TABLE app_public.tag IS
    e'A tag';

-- system
COMMENT ON COLUMN app_public.tag.id IS
    e'A tag’s id';
COMMENT ON COLUMN app_public.tag.created_at IS
    e'A tag’s create timestamp';
COMMENT ON COLUMN app_public.tag.updated_at IS
    e'A tag’s update timestamp';

-- scalar
COMMENT ON COLUMN app_public.tag.name IS
    e'A tag’s name';
COMMENT ON COLUMN app_public.tag.description IS
    e'A tag’s description';

--

CREATE TRIGGER timestamps
    BEFORE INSERT
    OR UPDATE ON app_public.tag
    FOR EACH ROW
    EXECUTE PROCEDURE app_private.tg__update_timestamps ();
