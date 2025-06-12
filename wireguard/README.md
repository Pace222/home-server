# Additional instructions

Include secrets at compose time:
```bash
sudo docker compose --env-file ${SECRETS_DIR:?}/wireguard/.env-compose up -d
sudo docker compose --env-file ${SECRETS_DIR:?}/wireguard/.env-compose down
```

To add a new peer, temporarily remove the read-only flag from the volume mount, just the time to rebuild the container, then put it back.
