#!/usr/bin/env bash

source ./.env.local

psql $DATABASE_URL -b -c "
BEGIN;

DROP SCHEMA IF EXISTS app_private CASCADE;
DROP SCHEMA IF EXISTS app_public CASCADE;
DROP SCHEMA IF EXISTS public CASCADE;
COMMIT;
"


echo 'Database dropped!'

