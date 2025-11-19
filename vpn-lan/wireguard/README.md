# Additional instructions

To add a new peer:

- Update `PEERS` in `${SECRETS_DIR:?}/wireguard/.env`
- Remove the read-only flag from the volume mount
- `docker compose up -d`
- `sudo -u dockeruser SLOW_VOLUMES=${SLOW_VOLUMES:?} chmod 700 ${SLOW_VOLUMES:?}/wireguard/config/peer*`
- Add the read-only flag back to the volume mount
- `docker compose up -d`
