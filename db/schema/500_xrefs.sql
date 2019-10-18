CREATE TABLE app_public.time_entry_tag_xref (
    time_entry_id uuid CONSTRAINT time_entry_id_fkey REFERENCES app_public.time_entry (id) ON DELETE SET NULL,
    tag_id uuid CONSTRAINT tag_id_fkey REFERENCES app_public.tag (id) ON DELETE SET NULL,
    PRIMARY KEY (time_entry_id, tag_id)
);

COMMENT ON TABLE app_public.time_entry_tag_xref IS E'Time entry & Tag junction';

-- COMMENT ON COLUMN app_public.time_entry_tag_xref.time_entry_id IS E'';
COMMENT ON CONSTRAINT time_entry_id_fkey ON app_public.time_entry_tag_xref IS E'@manyToManyFieldName timeEntries';

-- -- COMMENT ON COLUMN app_public.time_entry_tag_xref.tag_id IS E'';
COMMENT ON CONSTRAINT tag_id_fkey ON app_public.time_entry_tag_xref IS E'@manyToManyFieldName tags';

