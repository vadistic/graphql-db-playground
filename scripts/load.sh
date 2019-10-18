#!/usr/bin/env bash

source ./.env.local

psql $DATABASE_URL -b -c "
BEGIN;
  $(cat ./db/schema/*.sql)
COMMIT;
"

echo 'Database uploaded!'

psql $DATABASE_URL -b -c "
BEGIN;
  $(cat ./db/data/*.sql)
COMMIT;
"

echo 'Database seeded!'

