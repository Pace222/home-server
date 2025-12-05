#!/bin/sh
set -e

docker compose -f media-server/docker-compose.yml down

docker compose -f minecraft/docker-compose.yml down

docker compose -f ddclient/docker-compose.yml down
docker compose -f fw-monitor/docker-compose.yml down

docker compose -f int-homepage/docker-compose.yml down
docker compose -f grafana/docker-compose.yml down
docker compose -f int-proxy/docker-compose.yml down

docker compose -f dabloon-clicker/docker-compose.yml down
docker compose -f ext-homepage/docker-compose.yml down
docker compose -f authentik/docker-compose.yml down
docker compose -f ext-proxy/docker-compose.yml down

docker compose -f pihole/docker-compose.yml down

docker compose -f telegram-bot/docker-compose.yml down

docker compose -f monitoring/docker-compose.yml down
docker compose -f prometheus/docker-compose.yml down
docker compose -f loki/docker-compose.yml down
