# Additional instructions

To add a new peer:

- Update `${WIREGUARD_PEERS}`
- Remove the read-only flag from the volume mount
- `docker compose up -d`
- `sudo -u dockeruser SLOW_VOLUMES=${SLOW_VOLUMES:?} ./post_wg_peer.sh`
- Add the read-only flag back to the volume mount
- `docker compose up -d`
