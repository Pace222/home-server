# Welcome to my home server!

## Available from anywhere

- [External Homepage](/homepage) (https://pierugo.ch, https://www.pierugo.ch): A simple homepage that serves as a starting point for all the services I host.
- [Authentik](/authentik) (https://auth.pierugo.ch): An open-source identity provider that allows to manage users and their access to various services.
- [DabloonClicker](/dabloon-clicker) (https://dabloon.pierugo.ch): Mirror of CookieClicker but the sprites and text of the game are modified to click on dabloons instead of cookies.
- [WireGuard](/wireguard) (https://vpn.pierugo.ch): A VPN server that allows to connect to the home network securely from anywhere in the world.

## Available only from my home network or VPN

- [Internal Homepage](/homepage) (https://home.pierugo.ch): A more comprehensive homepage, also reaching the internal services.
- [Pi-hole](/pihole) (https://pihole.pierugo.ch): A DNS sinkhole that blocks ads and trackers at the network level. It also serves as a DNS server to resolve local hostnames.
- [Grafana](/monitoring) (https://grafana.pierugo.ch): A monitoring dashboard that collects and visualizes metrics from various services running on my home server.

## Internal services

- [Dynamic DNS](/ddclient): A dynamic DNS client that updates the DNS records of my domain with the current public IP address of my home network, in case my ISP decides to change it.
- [Telegram Bot](/telegram-bot): A logger for the Caddy servers: it sends a message to a Telegram channel on certain requests. It also serves an API to send any kind of message to Telegram. In practice, any service can thus send notifications or alert me on Telegram through this API.
- [Firewall monitoring](/fw-monitor): A service that monitors the firewall logs and sends notifications to Telegram on firewall drops, which would indicate a suspicious activity.
- [Prometheus and various exporters](/monitoring): A monitoring stack that collects metrics from various services running on my home server and visualizes them in Grafana.
