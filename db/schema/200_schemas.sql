--
CREATE SCHEMA IF NOT EXISTS app_public;

CREATE SCHEMA IF NOT EXISTS app_private;

--
ALTER DEFAULT privileges REVOKE EXECUTE ON functions FROM public;

