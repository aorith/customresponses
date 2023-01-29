#!/usr/bin/env bash
set -e
cd "$(dirname -- "$0")"
docker exec redis redis-cli flushdb
./create-examples.sh
