# Installation instructions

## SSH

- Generate a SSH key pair and add the public key to the host machine.
- Disable password authentication and X11 forwarding in the SSH configuration file.

## Directories and Environment Variables

Choose where to store the services, secrets, and Docker Compose files. Then set the following environment variables in your shell configuration file (e.g., `~/.bashrc`, `~/.zshrc`):

- `SERVICES_DIR=`
- `SECRETS_DIR=`
- `DOCKERS_DIR=`

Finally, for them to be passed through `sudo`, adapt the `sudoers` file by adding the following line:

```bash
Defaults        env_keep += "SERVICES_DIR SECRETS_DIR DOCKERS_DIR"
```

## Harden the system with firewall rules on containers that are not entirely on an internal network

```bash
# External proxy: Prevent communicating with LAN
sudo iptables -I DOCKER-USER 1 -d 172.18.0.2 -s 192.168.0.0/16 -j DROP
sudo iptables -I DOCKER-USER 2 -s 172.18.0.2 -d 192.168.0.0/16 -j DROP

# Internal proxy: Drop potential requests that would come from the external network
sudo iptables -I DOCKER-USER 3 -d 172.19.0.2 -s 192.168.1.150 -j DROP
sudo iptables -I DOCKER-USER 4 -s 172.19.0.2 -d 192.168.1.150 -j DROP

# Pihole: Drop potential requests that would come from the external network
sudo iptables -I DOCKER-USER 5 -d 172.20.0.2 -s 192.168.1.150 -j DROP
sudo iptables -I DOCKER-USER 6 -s 172.20.0.2 -d 192.168.1.150 -j DROP
```

## Install Docker

- `https://docs.docker.com/engine/install/debian/#install-using-the-repository`

## Build and run every Docker Compose file
