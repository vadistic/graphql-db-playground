-- TIME_ENTRY

-- cleanup

-- DROP TABLE IF EXISTS app_public.time_entry CASCADE;
-- DROP TRIGGER IF EXISTS timestamps ON app_public.time_entry;

--

CREATE TABLE app_public.time_entry (
    -- system
    id              uuid            PRIMARY KEY DEFAULT uuid_generate_v1mc (),
    created_at      TIMESTAMP       NOT NULL DEFAULT now(),
    updated_at      TIMESTAMP       NOT NULL DEFAULT now(),

    -- scalar
    name            text            CHECK (is_medium_text(name)),
    description     text,
    started_at      TIMESTAMP,
    ended_at        TIMESTAMP,

    -- refs
    account_id      uuid            NOT NULL
                                    REFERENCES app_public.account
                                    ON DELETE SET NULL,

    project_id      uuid            REFERENCES app_public.project
                                    ON DELETE SET NULL,

    client_id       uuid            REFERENCES app_public.client
                                    ON DELETE SET NULL
);

--

CREATE INDEX time_entry_account_id_fkey ON app_public.time_entry(account_id);
CREATE INDEX time_entry_project_id_fkey ON app_public.time_entry(project_id);
CREATE INDEX time_entry_client_id_fkey ON app_public.time_entry(client_id);

--

COMMENT ON TABLE app_public.time_entry IS
    e'A time entry';

-- system
COMMENT ON COLUMN app_public.time_entry.id IS
    e'A time entry’s id';
COMMENT ON COLUMN app_public.time_entry.created_at IS
    e'A time entry’s create timestamp';
COMMENT ON COLUMN app_public.time_entry.updated_at IS
    e'A time entry’s update timestamp';

-- scalar
COMMENT ON COLUMN app_public.time_entry.name IS
    e'A time entry’s name';
COMMENT ON COLUMN app_public.time_entry.description IS
    e'A time entry’s description';
COMMENT ON COLUMN app_public.time_entry.started_at IS
    e'A time entry’s start timestamp';
COMMENT ON COLUMN app_public.time_entry.ended_at IS
    e'A time entry’s end timestamp';

-- refs
COMMENT ON COLUMN app_public.time_entry.account_id IS
    e'A time entry’s author reference';
COMMENT ON COLUMN app_public.time_entry.project_id IS
    e'A time entry’s project reference';
COMMENT ON COLUMN app_public.time_entry.client_id IS
    e'A time entry’s client reference';

--

CREATE TRIGGER timestamps
    BEFORE INSERT OR UPDATE
    ON app_public.time_entry
    FOR EACH ROW EXECUTE PROCEDURE
    app_private.tg__update_timestamps ();

--