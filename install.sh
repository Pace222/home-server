#!/bin/sh
set -e

# This script installs and configures my home server on a new machine

# Constants
SSHD_CONFIG="/etc/ssh/sshd_config"
JOURNALD_CONFIG="/etc/systemd/journald.conf"
MAIN_USER="pace"
ROOTLESS_USER="dockeruser"

check_is_root() {
    # Check if script is run as root
    if [[ $EUID -ne 0 ]]; then
       echo "This script must be run as root" >&2
       exit 1
    fi
}

setup_ssh() {
    # Check that we do not lock ourselves out
    echo "Have you already put your public key in ~/.ssh/authorized_keys? (y/n)"
    read -r answer
    if [[ "$answer" != "y" ]]; then
        echo "Please add your public key to ~/.ssh/authorized_keys and run the script again."
        exit 0
    fi

    # Disable password authentication and X11 forwarding
    echo "Disabling password authentication and X11 forwarding for SSH..."
    if grep -qE "^\s*#?\s*PasswordAuthentication" "$SSHD_CONFIG"; then
        sed -i 's/^\s*#\?\s*PasswordAuthentication.*/PasswordAuthentication no/' "$SSHD_CONFIG"
    else
        echo "PasswordAuthentication no" >> "$SSHD_CONFIG"
    fi
    if grep -qE "^\s*#?\s*X11Forwarding" "$SSHD_CONFIG"; then
        sed -i 's/^\s*#\?\s*X11Forwarding.*/X11Forwarding no/' "$SSHD_CONFIG"
    else
        echo "X11Forwarding no" >> "$SSHD_CONFIG"
    fi
    
    echo "SSH successfully configured!"
}

use_rsyslog() {
    # Use rsyslog instead of journald
    echo "Installing rsyslog instead of journald"
    apt-get update && apt-get install -y rsyslog

    # Enable rsyslog to receive logs from journald
    if grep -qE "^\s*#?\s*ForwardToSyslog" "$JOURNALD_CONFIG"; then
        sed -i 's/^\s*#\?\s*ForwardToSyslog.*/ForwardToSyslog=yes/' "$JOURNALD_CONFIG"
    else
        echo "ForwardToSyslog=yes" >> "$JOURNALD_CONFIG"
    fi

    echo "Restarting journald and rsyslog services..."
    systemctl restart systemd-journald
    systemctl restart rsyslog

    echo "Rsyslog successfully configured to receive logs from journald!"
}

install_docker() {
    # Install Docker
    echo "Installing Docker..."
    apt-get update
    apt-get install -y ca-certificates curl
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update

    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    echo "Do you want to setup rootless Docker? (y/n)"
    read -r rootless_docker_answer
    if [[ "$rootless_docker_answer" == "y" ]]; then
        echo "Installing rootless Docker for user '$ROOTLESS_USER'..."

        apt-get install -y uidmap docker-ce-rootless-extras

        systemctl disable --now docker.service docker.socket
        rm /var/run/docker.sock

        # https://cmtops.dev/posts/rootless-docker-in-multiuser-environment/
        useradd -m -s $(which nologin) "$ROOTLESS_USER"
        groupadd -U "$MAIN_USER","$ROOTLESS_USER" rootlesskit
        loginctl enable-linger "$ROOTLESS_USER"
        machinectl shell "$ROOTLESS_USER"@ /bin/bash -c 'dockerd-rootless-setuptool.sh install'
        echo "net.ipv4.ip_unprivileged_port_start=0" >> /etc/sysctl.d/10-unprivileged-ports.conf
        cat << END > /usr/lib/tmpfiles.d/rootless.conf
        D /run/rootlesskit 1700 $ROOTLESS_USER $ROOTLESS_USER - - -
        a+ /run/rootlesskit - - - - g:rootlesskit:r-x,default:g:rootlesskit:rw-
        END

        cp ./install/override.conf /home/"$ROOTLESS_USER"/.config/systemd/user/docker.service.d/override.conf

        echo "Rootless Docker successfully installed for user '$ROOTLESS_USER'!"

        cp ./install/10-firewall.sh /home/"$ROOTLESS_USER"/.config/docker/firewall.sh
        echo "net.netfilter.nf_log_all_netns=1" >> /etc/sysctl.d/20-log-namespace-firewall.conf

        echo "Firewall rules set up."

        echo "You should reboot the system to apply all changes for rootless Docker."
        echo "Then run 'docker context create rootless --docker host=unix:///run/rootlesskit/docker.socket' to use rootless Docker."
    fi

    echo "Docker successfully installed!"
    echo "Firewall rules for rootful Docker are not set up by this script. Please refer to './install/10-firewall.sh' for inspiration."
}

cron_cleanup() {
    # Periodically delete unused data
    echo "Setting up periodic cleanup of unused Docker data..."
    (crontab -l && echo "0 0 * * 0 $(which docker) system prune -af >> /var/log/docker-prune.log 2>&1") | crontab -

    echo "Periodic cleanup of unused Docker data has been set up!"
}

setup_dirs_and_env() {
    # Setup directories and environment variables
    echo "Setting up directories and environment variables..."

    cp ./install/.serverrc "$HOME/.serverrc"
    echo "source \$HOME/.serverrc" >> "$HOME/.bashrc"

    echo "Directories and environment variables successfully set up!"
}

create_networks() {
    # Create Docker networks
    echo "Creating Docker networks..."

    # External subnet
    docker network create --internal --subnet=172.18.2.0/26 --gateway=172.18.2.1 net-ext-homepage
    docker network create --internal --subnet=172.18.3.0/24 --gateway=172.18.3.1 net-dabloon
    docker network create --internal --subnet=172.18.4.0/26 --gateway=172.18.4.1 net-authentik
    # 172.18.5.0/24 used by CS2
    # 172.18.6.0/24 used by Minecraft
    docker network create --internal --subnet=172.18.7.0/28 --gateway=172.18.7.1 net-ext-media

    # Internal subnet
    docker network create --internal --subnet=172.19.2.0/26 --gateway=172.19.2.1 net-int-homepage
    docker network create --internal --subnet=172.19.3.0/25 --gateway=172.19.3.1 net-pihole
    docker network create --internal --subnet=172.19.4.0/25 --gateway=172.19.4.1 net-ddclient
    docker network create --internal --subnet=172.19.5.0/24 --gateway=172.19.5.1 net-fw-monitor
    docker network create --internal --subnet=172.19.6.0/26 --gateway=172.19.6.1 net-grafana
    docker network create --internal --subnet=172.19.7.0/26 --gateway=172.19.7.1 net-loki
    docker network create --internal --subnet=172.19.8.0/28 --gateway=172.19.8.1 net-int-media

    # Communication with Prometheus
    docker network create --internal  --subnet=172.21.1.0/24  --gateway=172.21.1.1 prom-wg
    docker network create --internal  --subnet=172.21.2.0/24  --gateway=172.21.2.1 prom-ext-caddy
    docker network create --internal  --subnet=172.21.3.0/24  --gateway=172.21.3.1 prom-int-caddy
    docker network create --internal  --subnet=172.21.4.0/24  --gateway=172.21.4.1 prom-authentik
    docker network create --internal  --subnet=172.21.5.0/24  --gateway=172.21.5.1 prom-grafana
    docker network create --internal  --subnet=172.21.6.0/24  --gateway=172.21.6.1 prom-cadvisor
    docker network create --internal  --subnet=172.21.7.0/24  --gateway=172.21.7.1 prom-node-exporter
    docker network create --internal  --subnet=172.21.8.0/24  --gateway=172.21.8.1 prom-jellyfin
    docker network create --internal  --subnet=172.21.9.0/24  --gateway=172.21.9.1 prom-flaresolverr
    docker network create --internal --subnet=172.21.10.0/24 --gateway=172.21.10.1 prom-qui
    docker network create --internal --subnet=172.21.11.0/24 --gateway=172.21.11.1 prom-autobrr
    docker network create --internal --subnet=172.21.12.0/24 --gateway=172.21.12.1 prom-scraparr
    docker network create --internal --subnet=172.21.13.0/24 --gateway=172.21.13.1 prom-int-homepage
}

add_media_group() {
    # Add media group
    echo "Adding media group..."

    echo "$ROOTLESS_USER:1003:1" >> /etc/subuid # Such that host's  user `media` (UID 1003) is mapped to a non-nobody  user in rootless Docker
    echo "$ROOTLESS_USER:1003:1" >> /etc/subgid # Such that host's group `media` (GID 1003) is mapped to a non-nobody group in rootless Docker
    useradd -m media -u 1003 -s /sbin/nologin
    usermod -aG media "$MAIN_USER"
    echo "$ROOTLESS_USER:4:1" >> /etc/subgid    # Such that host's group `adm` (GID 4) is mapped to a non-nobody group in rootless Docker

    echo "Media group successfully added!"
}

restart_ssh() {
    # Restart the SSH service to apply changes
    echo "Restarting SSH service... Bye bye!"
    systemctl restart sshd

    echo "SSH service restarted successfully! (You should probably not see this message)"
}

main() {
    echo "Starting home server setup..."

    echo "Disclaimer  : This script assumes you are using Debian or a Debian-based distribution and Bash as your shell."
    echo "Disclaimer 2: This script was not actually ever ran. It is merely a collection of commands I would run to setup a new home server, so use at your own risk."

    check_is_root

    echo "Do you want to setup SSH? (y/n)"
    read -r setup_ssh_answer
    if [[ "$setup_ssh_answer" == "y" ]]; then
        setup_ssh
    fi

    echo "Do you want to setup the logging system to monitor firewall logs? (y/n)"
    read -r setup_logging_answer
    if [[ "$setup_logging_answer" == "y" ]]; then
        use_rsyslog
    fi

    echo "Do you want to install Docker? (y/n)"
    read -r install_docker_answer
    if [[ "$install_docker_answer" == "y" ]]; then
        install_docker
    fi

    echo "Do you want to setup periodic cleanup of unused Docker data? (y/n)"
    read -r cron_cleanup_answer
    if [[ "$cron_cleanup_answer" == "y" ]]; then
        cron_cleanup
    fi

    echo "Do you want to setup directories and environment variables? (y/n)"
    read -r setup_dirs_answer
    if [[ "$setup_dirs_answer" == "y" ]]; then
        setup_dirs_and_env
    fi

    echo "Do you want to create Docker networks? (y/n)"
    read -r create_networks_answer
    if [[ "$create_networks_answer" == "y" ]]; then
        create_networks
    fi

    echo "Do you want to add the media group? (y/n)"
    read -r add_media_group_answer
    if [[ "$add_media_group_answer" == "y" ]]; then
        add_media_group
    fi

    if [[ "$setup_ssh_answer" == "y" ]]; then
        restart_ssh
    fi

    echo "Home server setup completed successfully!"
}

# Main script execution
main()
