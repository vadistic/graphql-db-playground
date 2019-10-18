#!/usr/bin/env bash

eval $(cat .env.vm)

docker-compose down --rmi local -v --remove-orphans
