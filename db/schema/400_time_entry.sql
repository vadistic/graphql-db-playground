CREATE TABLE app_public.time_entry (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v1mc (),
    created_at timestamp DEFAULT now(),
    updated_at timestamp DEFAULT now(),
    --
    name text CHECK (char_length(name) < 200),
    description text,
    started_at timestamp,
    ended_at timestamp,
    --
    account_id uuid REFERENCES app_public.account ON DELETE SET NULL
);

--
COMMENT ON TABLE app_public.time_entry IS E'A time entry.';

COMMENT ON COLUMN app_public.time_entry.id IS E'A time entry’s id';

COMMENT ON COLUMN app_public.time_entry.created_at IS E'Time entry’s create timestamp';

COMMENT ON COLUMN app_public.time_entry.updated_at IS E'Time entry’s update timestamp';

--
CREATE TRIGGER timestamps
    BEFORE INSERT
    OR UPDATE ON app_public.time_entry
    FOR EACH ROW
    EXECUTE PROCEDURE app_private.tg__update_timestamps ();

