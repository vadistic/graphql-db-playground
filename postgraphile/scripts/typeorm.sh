#!/usr/bin/env bash

source ./.env.local

yarn typeorm-model-generator \
  --engine postgres \
  --database $DATABASE_NAME \
  --user $DATABASE_USER \
  --pass $DATABASE_PASSWORD \
  --port $DATABASE_PORT \
  --schema $DATABASE_SCHEMA \
  --output ./generated
