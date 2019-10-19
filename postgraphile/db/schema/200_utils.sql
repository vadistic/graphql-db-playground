-- UTILS

-- cleanup

-- drop function if exists app_private.tg__update_timestamps cascade;
-- drop function if exists is_timezone_name cascade;
-- drop function if exists is_short_text cascade;
-- drop function if exists is_medium_text cascade;

--

create function app_private.tg__update_timestamps () returns trigger as $$
begin
    new.created_at = (
        case when old.created_at is not null then
            old.created_at
        else
            now()
        end);
    new.updated_at = now();
    return new;
end;
$$ language plpgsql volatile;

comment on function app_private.tg__update_timestamps () is
    e'This trigger should be called on all tables with created_at, updated_at';

--

create function is_timezone_name (value text) returns boolean as $$
    SELECT EXISTS (
        SELECT 1
            FROM pg_timezone_names
            WHERE name=value AND value NOT LIKE 'posix/%'
    );
$$ language sql stable;

--

create function is_short_text (value text) returns boolean as $$
   begin
    return char_length(value) < 70;
   end
$$ language plpgsql immutable strict;

--

create function is_medium_text (value text) returns boolean as $$
   begin
    return char_length(value) < 140;
   end
$$ language plpgsql immutable strict;