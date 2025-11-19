#!/bin/sh
set -e

docker compose -f loki/docker-compose.yml up -d
docker compose -f prometheus/docker-compose.yml up -d
docker compose -f monitoring/docker-compose.yml up -d

docker compose -f telegram-bot/docker-compose.yml up -d

docker compose -f pihole/docker-compose.yml up -d

docker compose -f wireguard/docker-compose.yml up -d

docker compose -f ext-proxy/docker-compose.yml up -d
docker compose -f authentik/docker-compose.yml up -d
docker compose -f ext-homepage/docker-compose.yml up -d
docker compose -f dabloon-clicker/docker-compose.yml up -d

docker compose -f int-proxy/docker-compose.yml up -d
docker compose -f grafana/docker-compose.yml up -d
docker compose -f int-homepage/docker-compose.yml up -d

docker compose -f fw-monitor/docker-compose.yml up -d
docker compose -f ddclient/docker-compose.yml up -d

docker compose -f minecraft/docker-compose.yml up -d
