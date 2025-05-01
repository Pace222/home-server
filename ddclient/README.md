# Additional instructions

Include secrets at compose time:
```bash
sudo docker compose --env-file ${SECRETS_DIR:?}/ddclient/.env up -d
sudo docker compose --env-file ${SECRETS_DIR:?}/ddclient/.env down
```
