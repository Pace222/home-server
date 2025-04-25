# Additional instructions

Clone the repository:
```bash
git clone git@github.com:Pace222/home-telegram-bot.git ${SERVICES_DIR:?}/telegram-bot
```

Include secrets at compose time:
```bash
sudo docker compose --env-file ${SECRETS_DIR}/telegram-bot/.env up -d
sudo docker compose --env-file ${SECRETS_DIR}/telegram-bot/.env down
```
