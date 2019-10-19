-- XREFS

-- DROP TABLE IF EXISTS app_public.time_entry_tag_xref;
-- DROP TABLE IF EXISTS app_public.account_workspace_tag_xref;

-- TIME_ENTRY <> TAG

CREATE TABLE app_public.time_entry_tag_xref (
    time_entry_id   uuid            CONSTRAINT time_entry_id_fkey REFERENCES app_public.time_entry(id) ON DELETE SET NULL,
    tag_id          uuid            CONSTRAINT tag_id_fkey        REFERENCES app_public.tag(id)        ON DELETE SET NULL,

    PRIMARY KEY (time_entry_id, tag_id)
);

COMMENT ON TABLE app_public.time_entry_tag_xref IS
    e'Time entry & Tag association';

COMMENT ON CONSTRAINT time_entry_id_fkey ON app_public.time_entry_tag_xref IS
    e'@manyToManyFieldName timeEntries\n@manyToManySimpleFieldName timeEntriesList';

COMMENT ON CONSTRAINT tag_id_fkey ON app_public.time_entry_tag_xref IS
    e'@manyToManyFieldName tags\n@manyToManySimpleFieldName tagsList';

-- ACCOUNT <> WORKSPACE

CREATE TABLE app_public.account_workspace_xref (
    account_id      uuid            CONSTRAINT account_id_fkey    REFERENCES app_public.account(id)    ON DELETE SET NULL,
    workspace_id    uuid            CONSTRAINT workspace_id_fkey  REFERENCES app_public.workspace(id)  ON DELETE SET NULL,

    PRIMARY KEY (account_id, workspace_id)
);

COMMENT ON TABLE app_public.account_workspace_xref IS
    e'Account & Workspace association';

COMMENT ON CONSTRAINT account_id_fkey ON app_public.account_workspace_xref IS
    e'@manyToManyFieldName accounts\n@manyToManySimpleFieldName accountsList';

COMMENT ON CONSTRAINT workspace_id_fkey ON app_public.account_workspace_xref IS
    e'@manyToManyFieldName workspaces\n@manyToManySimpleFieldName workspacesList';

-- ACCOUNT <> PROJECT

CREATE TABLE app_public.account_project_xref (
    account_id      uuid        CONSTRAINT account_id_fkey    REFERENCES app_public.account    ON DELETE SET NULL,
    project_id      uuid        CONSTRAINT project_id_fkey    REFERENCES app_public.project    ON DELETE SET NULL,

    PRIMARY KEY (account_id, project_id)
);

COMMENT ON TABLE app_public.account_project_xref IS
    e'Account & Project association';

COMMENT ON CONSTRAINT account_id_fkey ON app_public.account_project_xref IS
    e'@manyToManyFieldName accounts\n@manyToManySimpleFieldName accountsList';

COMMENT ON CONSTRAINT project_id_fkey ON app_public.account_project_xref IS
    e'@manyToManyFieldName projects\n@manyToManySimpleFieldName projectsList';
