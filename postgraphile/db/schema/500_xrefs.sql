-- XREFS

-- drop table if exists app_public.time_entry_tag_xref;
-- drop table if exists app_public.account_workspace_xref;
-- drop table if exists app_public.account_project_xref;

-- TIME_ENTRY <> TAG

create table app_public.time_entry_tag_xref (
    time_entry_id   uuid            constraint time_entry_id_fkey references app_public.time_entry(id) on delete set null,
    tag_id          uuid            constraint tag_id_fkey        references app_public.tag(id)        on delete set null,

    primary key (time_entry_id, tag_id)
);

comment on table app_public.time_entry_tag_xref is
    e'@omit all,many\nTime entry & Tag association';

comment on constraint time_entry_id_fkey on app_public.time_entry_tag_xref is
    e'@manyToManyFieldName timeEntries\n@manyToManySimpleFieldName timeEntriesList';

comment on constraint tag_id_fkey on app_public.time_entry_tag_xref is
    e'@manyToManyFieldName tags\n@manyToManySimpleFieldName tagsList';

grant select, insert, update, delete on table app_public.time_entry_tag_xref to app_authenticated;

-- ACCOUNT <> WORKSPACE

create table app_public.account_workspace_xref (
    account_id      uuid            constraint account_id_fkey    references app_public.account(id)    on delete set null,
    workspace_id    uuid            constraint workspace_id_fkey  references app_public.workspace(id)  on delete set null,

    primary key (account_id, workspace_id)
);

comment on table app_public.account_workspace_xref is
    e'@omit all,many\nAccount & Workspace association';

comment on constraint account_id_fkey on app_public.account_workspace_xref is
    e'@manyToManyFieldName accounts\n@manyToManySimpleFieldName accountsList';

comment on constraint workspace_id_fkey on app_public.account_workspace_xref is
    e'@manyToManyFieldName workspaces\n@manyToManySimpleFieldName workspacesList';

grant select, insert, update, delete  on table app_public.account_workspace_xref to app_authenticated;

-- ACCOUNT <> PROJECT

create table app_public.account_project_xref (
    account_id      uuid        constraint account_id_fkey    references app_public.account    on delete set null,
    project_id      uuid        constraint project_id_fkey    references app_public.project    on delete set null,

    primary key (account_id, project_id)
);

comment on table app_public.account_project_xref is
    e'@omit all,many\nAccount & Project association';

comment on constraint account_id_fkey on app_public.account_project_xref is
    e'@manyToManyFieldName accounts\n@manyToManySimpleFieldName accountsList';

comment on constraint project_id_fkey on app_public.account_project_xref is
    e'@manyToManyFieldName projects\n@manyToManySimpleFieldName projectsList';

grant select, insert, update, delete  on table app_public.account_project_xref to app_authenticated;
