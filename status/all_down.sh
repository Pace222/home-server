#!/bin/sh
set -e

docker compose -f uptime/docker-compose.yml down

docker compose -f ext-proxy/docker-compose.yml down
