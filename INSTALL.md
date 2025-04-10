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
# Setup LOG_DROP chain
sudo iptables -N LOG_DROP
sudo iptables -A LOG_DROP                                                              -j LOG --log-prefix "DROP: "
sudo iptables -A LOG_DROP                                                              -j DROP

# External subnet: Prevent communicating with other containers through any local IP
sudo iptables -I INPUT       1 -s             172.18.0.0/16 -m addrtype --dst-type LOCAL -j LOG_DROP
sudo iptables -I OUTPUT      1 -s             172.18.0.0/16 -m addrtype --dst-type LOCAL -j LOG_DROP
sudo iptables -I OUTPUT      2 -m addrtype --src-type LOCAL -d             172.18.0.0/16 -j LOG_DROP
sudo iptables -I INPUT       2 -m addrtype --src-type LOCAL -d             172.18.0.0/16 -j LOG_DROP
# External subnet: Prevent communicating with LAN
sudo iptables -I DOCKER-USER 1 -s             172.18.0.0/16 -d            192.168.0.0/16 -j LOG_DROP
sudo iptables -I OUTPUT      3 -s             172.18.0.0/16 -d            192.168.0.0/16 -j LOG_DROP
sudo iptables -I DOCKER-USER 2 -s            192.168.0.0/16 -d             172.18.0.0/16 -j LOG_DROP
sudo iptables -I INPUT       3 -s            192.168.0.0/16 -d             172.18.0.0/16 -j LOG_DROP
```

## Install Docker

- `https://docs.docker.com/engine/install/debian/#install-using-the-repository`

## Build and run every Docker Compose file
