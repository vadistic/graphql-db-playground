CREATE FUNCTION app_private.tg__update_timestamps ()
    RETURNS TRIGGER
    AS $$
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
$$
LANGUAGE plpgsql
VOLATILE;

COMMENT ON FUNCTION app_private.tg__update_timestamps () IS E'This trigger should be called on all tables with created_at, updated_at - it ensures that they cannot be manipulated and that updated_at will always be larger than the previous updated_at.';

