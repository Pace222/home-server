# Welcome to my home server!

## Available from anywhere

- [DabloonClicker](/dabloon-clicker) (https://dabloon.pierugo.ch): Mirror of CookieClicker but the sprites and text of the game are modified to click on dabloons instead of cookies.

- [WireGuard](/wireguard) (https://vpn.pierugo.ch): A VPN server that allows to connect to the home network securely from anywhere in the world.

## Available only from my home network or VPN

- [Pi-hole](/pihole) (https://pihole.pierugo.ch): A DNS sinkhole that blocks ads and trackers at the network level. It also serves as a DNS server to resolve local hostnames.

## Internal services

- [Dynamic DNS](/ddclient): A dynamic DNS client that updates the DNS records of my domain with the current public IP address of my home network, in case my ISP decides to change it.
- [Telegram Bot](/telegram-bot): A logger for the Caddy servers: it sends a message to a Telegram channel on certain requests. It also serves an API to send any kind of message to Telegram. In practice, any service can thus send notifications or alert me on Telegram through this API.
