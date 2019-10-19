-- UTILS

-- cleanup

-- DROP FUNCTION IF EXISTS app_private.tg__update_timestamps CASCADE;
-- DROP FUNCTION IF EXISTS is_timezone_name CASCADE;
-- DROP FUNCTION IF EXISTS is_short_text CASCADE;
-- DROP FUNCTION IF EXISTS is_medium_text CASCADE;

--

CREATE FUNCTION app_private.tg__update_timestamps () RETURNS TRIGGER AS $$
BEGIN
    NEW.created_at = (
        CASE WHEN OLD.created_at IS NOT NULL THEN
            OLD.created_at
        ELSE
            NOW()
        END);
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE PLPGSQL VOLATILE;

COMMENT ON FUNCTION app_private.tg__update_timestamps () IS
    e'This trigger should be called on all tables with created_at, updated_at';

--

CREATE FUNCTION is_timezone_name (INPUT text) RETURNS boolean AS $$
    SELECT EXISTS (
        SELECT 1
            FROM pg_timezone_names
            WHERE name=INPUT AND INPUT NOT LIKE 'posix/%'
    );
$$ LANGUAGE SQL STABLE;

CREATE FUNCTION is_short_text (INPUT text) RETURNS boolean AS $$
   BEGIN
    RETURN char_length(INPUT) < 70;
   END
$$ LANGUAGE PLPGSQL IMMUTABLE STRICT;

CREATE FUNCTION is_medium_text (INPUT text) RETURNS boolean AS $$
   BEGIN
    RETURN char_length(INPUT) < 140;
   END
$$ LANGUAGE PLPGSQL IMMUTABLE STRICT;