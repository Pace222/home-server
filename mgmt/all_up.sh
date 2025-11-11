#!/bin/sh
set -e

docker compose -f int-proxy/docker-compose.yml up -d
