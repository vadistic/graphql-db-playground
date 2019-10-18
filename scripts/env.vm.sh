#!/usr/bin/env bash

# https://gist.github.com/judy2k/7656bfe3b322d669ef75364a46327836#gistcomment-2993455
set -a
[ -f ./.env.vm ] && source ./.env.vm
set +a

echo 'Local envs loaded for : '$DATABASE_ADMIN_URL
