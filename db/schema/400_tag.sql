CREATE TABLE app_public.tag (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v1mc (),
    created_at timestamp DEFAULT now(),
    updated_at timestamp DEFAULT now(),
    name text NOT NULL CHECK (char_length(name) < 60),
    description text
);

--
COMMENT ON TABLE app_public.tag IS E'A tag';

COMMENT ON COLUMN app_public.tag.id IS E'Tag id';

COMMENT ON COLUMN app_public.tag.created_at IS E'Tag create timestamp';

COMMENT ON COLUMN app_public.tag.updated_at IS E'Tag update timestamp';

COMMENT ON COLUMN app_public.tag.name IS E'Tag name';

COMMENT ON COLUMN app_public.tag.description IS E'Tag description';

--
CREATE TRIGGER timestamps
    BEFORE INSERT
    OR UPDATE ON app_public.tag
    FOR EACH ROW
    EXECUTE PROCEDURE app_private.tg__update_timestamps ();

