# Welcome to my home server!

## Available from anywhere

- [External Homepage](/prod/homepage) (https://pierugo.ch, https://www.pierugo.ch): A simple homepage that serves as a starting point for all the services I host.
- [Authentik](/prod/authentik) (https://auth.pierugo.ch): An open-source identity provider that allows to manage users and their access to all services on the home server.
- [DabloonClicker](/prod/dabloon-clicker) (https://dabloon.pierugo.ch): Mirror of CookieClicker but the sprites and text of the game are modified to click on dabloons instead of cookies.
- [WireGuard](/vpn-lan/wireguard) (vpn.pierugo.ch): A VPN server that allows to connect to the home network securely from anywhere in the world.
- [Minecraft Server](/prod/minecraft) (mc.pierugo.ch): A Minecraft server that I host for me and my friends to play together.
- [CS2 Server](/prod/cs2) (cs2.pierugo.ch): A Counter-Strike 2 server that I (also) host for me and my friends to play together.
- [Jellyfin](/prod/media-server) (https://tv.pierugo.ch): A media server that allows to stream my personal collection of movies and TV shows to any device.
- [Seerr](/prod/media-server) (https://requests.tv.pierugo.ch): A media request and management system that integrates with Jellyfin to allow users to request new content and manage their media library.

## Available only from my home network or VPN

- [Internal Homepage](/prod/homepage) (https://home.pierugo.ch): A more comprehensive homepage, displaying links also for internal services.
- [Pi-hole](/prod/pihole) (https://pihole.pierugo.ch): A DNS sinkhole that blocks ads and trackers at the network level. It also serves as a DNS server to resolve local hostnames.
- [Grafana](/prod/grafana) (https://grafana.pierugo.ch): A monitoring dashboard that collects and visualizes metrics from various services running on my home server.
- [Radarr/Sonarr](/prod/media-server) (https://radarr.pierugo.ch, https://sonarr.pierugo.ch): Automated media downloaders that integrate with my media server to automatically download movies and TV shows based on my preferences.
- [Prowlarr](/prod/media-server) (https://prowlarr.pierugo.ch): An indexer manager that integrates with Radarr and Sonarr to manage and organize the various indexers used for media downloads.
- [qBittorrent](/prod/media-server) (https://torrents.pierugo.ch): A torrent client that I use to download media files, which are then automatically organized and added to my media server by Radarr and Sonarr.

## Internal services

- [Dynamic DNS](/prod/ddclient): A dynamic DNS client that updates the DNS records of my domain with the current public IP address of my home network, in case my ISP decides to change it.
- [Telegram Bot](/prod/telegram-bot): Serves an API to send any kind of message to Telegram. Any service can thus send notifications or alert me on Telegram through this API.
- [Firewall monitoring](/prod/fw-monitor) (soon to be superseded by Alloy): A service that monitors the firewall logs and sends notifications to Telegram on firewall drops, which would indicate a suspicious activity.
- [Prometheus](/prod/prometheus): A monitoring system that collects metrics from various services running on my home server and makes them available to Grafana for visualization.
- [Loki](/prod/loki), together with [Alloy](/prod/loki): _Like Prometheus, but for logs._
- [Various exporters](/prod/monitoring): A few monitoring exports that collect general metrics from the host system and each individual container, such as CPU and memory usage, disk space, network traffic, etc.

## Development services

All the above URLs have their counterpart as https://\*.dev.pierugo.ch, which point to a copy of these services running in a separate VM (and VLAN!), used for development and testing purposes. This way, I can test new configurations, updates, or features before affecting the production services.
