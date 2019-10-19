#!/usr/bin/env bash

source ./.env.local

# separate for sane error logging
find ./db/schema -name '*.sql' | sort | xargs -I _ sh -c "psql $DATABASE_ADMIN_URL -b -q -f _ && echo 'OK: _'"

echo 'Database uploaded!'

find ./db/data -name '*.sql' | sort | xargs -I _ psql $DATABASE_ADMIN_URL -b -q -f _

echo 'Database seeded!'
