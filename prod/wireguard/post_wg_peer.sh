#!/bin/sh

# drwxr-xr-x -> drwx------
chmod 700 ${SLOW_VOLUMES:?}/wireguard/config/peer*

# wireguard-exporter
sed -i -E 's/^# peer_?(.*)/# friendly_name = \1/' ${SLOW_VOLUMES:?}/wireguard/config/wg_confs/wg0.conf
