# Additional instructions

Clone the repository:
```bash
git clone git@github.com:Pace222/home-server-media.git ${CONFIGS_DIR:?}/media
```

Include secrets at compose time:
```bash
sudo docker compose --env-file ${SECRETS_DIR:?}/authentik/.env up -d
sudo docker compose --env-file ${SECRETS_DIR:?}/authentik/.env down
```
