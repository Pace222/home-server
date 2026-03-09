#!/bin/sh
set -e

docker compose -f ext-proxy/docker-compose.yml up -d

docker compose -f uptime/docker-compose.yml up -d
