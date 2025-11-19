#!/bin/sh
set -e

docker compose -f wireguard/docker-compose.yml up -d
