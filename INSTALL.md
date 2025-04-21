# Installation instructions

## SSH

- Generate a SSH key pair and add the public key to the host machine.
- Disable password authentication and X11 forwarding in the SSH configuration file.

## Install Docker

- `https://docs.docker.com/engine/install/debian/#install-using-the-repository`

## Directories and Environment Variables

Choose your domain, and where to store the services, secrets, and Docker Compose files. Then set the following environment variables in your shell configuration file (e.g., `~/.bashrc`, `~/.zshrc`):

- `MY_DOMAIN=`
- `SERVICES_DIR=`
- `SECRETS_DIR=`
- `DOCKERS_DIR=`

Finally, for them to be passed through `sudo`, adapt the `sudoers` file by adding the following line:

```bash
Defaults        env_keep += "MY_DOMAIN SERVICES_DIR SECRETS_DIR DOCKERS_DIR"
```

## Create the networks

```bash
# External subnet
sudo docker network create --internal --subnet=172.18.1.0/24 --gateway=172.18.1.1 net-dabloon
# Internal subnet
sudo docker network create --internal --subnet=172.19.1.0/24 --gateway=172.19.1.1 net-pihole

```

## Harden the system with firewall rules on external-facing containers

```bash
# Setup LOG_DROP chain
sudo iptables -N LOG_DROP
sudo iptables -A LOG_DROP                                                                -j LOG --log-prefix "DROP: "
sudo iptables -A LOG_DROP                                                                -j DROP

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

# Save the rules
sudo apt-get install -y iptables-persistent
```

## Push all secrets to the host machine

On the local machine:

```bash
$SECRETS_DIR/push_secrets.sh
```

## Run all services

Go in every directory, follow eventual instructions in the respective `README.md` file and run `sudo docker compose up -d`.
