# Additional instructions

Include secrets at compose time:
```bash
sudo docker compose --env-file ${SECRETS_DIR:?}/monitoring/.env up -d
sudo docker compose --env-file ${SECRETS_DIR:?}/monitoring/.env down
```
