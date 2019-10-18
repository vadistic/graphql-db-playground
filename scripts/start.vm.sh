#!/usr/bin/env bash

sh scripts/env.vm.sh

yarn postgraphile \
      --connection $DATABASE_APP_URL \
      --port 5000 \
      --schema app_public \
      --retry-on-init-fail \
      --dynamic-json \
      --show-error-stack \
      --extended-errors hint,detail,errcode \
      --graphql /graphql \
      --graphiql /graphiql \
      --enhance-graphiql \
      --watch
