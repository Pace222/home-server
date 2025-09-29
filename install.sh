#!/bin/sh
set -e

# This script installs and configures my home server on a new machine

# Constants
SSHD_CONFIG="/etc/ssh/sshd_config"
JOURNALD_CONFIG="/etc/systemd/journald.conf"

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
    curl -fsSL https://get.docker.com | sh

    echo "Docker successfully installed!"
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

    local rcfile="$HOME/.bashrc"

    # Ask the user
    echo "What is the domain name?"
    read -r domain_name
    echo "In what folder do you want to store the configs? (e.g. /srv/configs)"
    read -r configs_folder
    echo "In what folder do you want to store the services? (e.g. /srv/services)"
    read -r services_folder
    echo "In what folder do you want to store the secrets? (e.g. /srv/secrets)"
    read -r secrets_folder
    echo "In what folder do you want to store the docker compose files? (e.g. /srv/dockers)"
    read -r dockers_folder
    echo "What is the Proxmox IP?"
    read -r proxmox_ip
    echo "What is the DNS IP?"
    read -r dns_ip
    echo "What is the VPN IP?"
    read -r vpn_ip
    echo "What is the external proxy IP?"
    read -r ext_proxy_ip
    echo "What is the internal proxy IP?"
    read -r int_proxy_ip

    # Directories
    mkdir -p "$config_folder" "$services_folder" "$secrets_folder" "$docker_folder"

    # Environment variables
    echo "export MY_DOMAIN=\"$domain_name\"" >> "$rcfile"
    echo >> "$rcfile"
    echo "# Directories environment variables" >> "$rcfile"
    echo "export CONFIGS_DIR=\"$configs_folder\"" >> "$rcfile"
    echo "export SERVICES_DIR=\"$services_folder\"" >> "$rcfile"
    echo "export SECRETS_DIR=\"$secrets_folder\"" >> "$rcfile"
    echo "export DOCKERS_DIR=\"$dockers_folder\"" >> "$rcfile"
    echo "alias configs=\"cd \$CONFIGS_DIR\"" >> "$rcfile"
    echo "alias services=\"cd \$SERVICES_DIR\"" >> "$rcfile"
    echo "alias secrets=\"cd \$SECRETS_DIR\"" >> "$rcfile"
    echo "alias dockers=\"cd \$DOCKERS_DIR\"" >> "$rcfile"
    echo >> "$rcfile"
    echo "# Networking environment variables" >> "$rcfile"
    echo "export PROXMOX_IP=\"$proxmox_ip\"" >> "$rcfile"
    echo "export DNS_IP=\"$dns_ip\"" >> "$rcfile"
    echo "export VPN_IP=\"$vpn_ip\"" >> "$rcfile"
    echo "export EXT_PROXY_IP=\"$ext_proxy_ip\"" >> "$rcfile"
    echo "export INT_PROXY_IP=\"$int_proxy_ip\"" >> "$rcfile"
    echo >> "$rcfile"
    echo "# Secrets" >> "$rcfile"
    echo "source $SECRETS_DIR/.env-compose"

    echo "Directories and environment variables successfully set up!"
}

create_networks() {
    # Create Docker networks
    echo "Creating Docker networks..."

    # External subnet
    docker network create --internal --subnet=172.18.2.0/26 --gateway=172.18.2.1 net-ext-homepage
    docker network create --internal --subnet=172.18.3.0/24 --gateway=172.18.3.1 net-dabloon
    docker network create --internal --subnet=172.18.4.0/26 --gateway=172.18.4.1 net-authentik
    # Internal subnet
    docker network create --internal --subnet=172.19.2.0/26 --gateway=172.19.2.1 net-int-homepage
    docker network create --internal --subnet=172.19.3.0/25 --gateway=172.19.3.1 net-pihole
    docker network create --internal --subnet=172.19.4.0/25 --gateway=172.19.4.1 net-ddclient
    docker network create --internal --subnet=172.19.5.0/24 --gateway=172.19.5.1 net-fw-monitor
    docker network create --internal --subnet=172.19.6.0/26 --gateway=172.19.6.1 net-grafana

    # Communication with Prometheus
    docker network create --internal --subnet=172.21.1.0/24 --gateway=172.21.1.1 prom-wg
    docker network create --internal --subnet=172.21.2.0/24 --gateway=172.21.2.1 prom-ext-caddy
    docker network create --internal --subnet=172.21.3.0/24 --gateway=172.21.3.1 prom-int-caddy
    docker network create --internal --subnet=172.21.4.0/24 --gateway=172.21.4.1 prom-authentik
    docker network create --internal --subnet=172.21.5.0/24 --gateway=172.21.5.1 prom-grafana
    docker network create --internal --subnet=172.21.6.0/24 --gateway=172.21.6.1 prom-cadvisor
    docker network create --internal --subnet=172.21.7.0/24 --gateway=172.21.7.1 prom-node-exporter
}

firewall_rules() {
    # Create firewall rules
    echo "Setting up firewall rules..."

    if ! command -v iptables &>/dev/null; then
        echo "iptables is not installed. Please install it first."
        exit 1
    fi

    # Setup LOG_DROP chain
    iptables -N LOG_DROP
    iptables -A LOG_DROP                                                                -j LOG --log-prefix "FW_DROP: "
    iptables -A LOG_DROP                                                                -j DROP

    # External subnet: Prevent communicating with other containers through any local IP
    iptables -I INPUT       1 -s             172.18.0.0/16 -m addrtype --dst-type LOCAL -j LOG_DROP
    iptables -I OUTPUT      1 -s             172.18.0.0/16 -m addrtype --dst-type LOCAL -j LOG_DROP
    iptables -I OUTPUT      2 -m addrtype --src-type LOCAL -d             172.18.0.0/16 -j LOG_DROP
    iptables -I INPUT       2 -m addrtype --src-type LOCAL -d             172.18.0.0/16 -j LOG_DROP
    # External subnet: Prevent communicating with LAN
    iptables -I DOCKER-USER 1 -s             172.18.0.0/16 -d            192.168.0.0/16 -j LOG_DROP
    iptables -I OUTPUT      3 -s             172.18.0.0/16 -d            192.168.0.0/16 -j LOG_DROP
    iptables -I DOCKER-USER 2 -s            192.168.0.0/16 -d             172.18.0.0/16 -j LOG_DROP
    iptables -I INPUT       3 -s            192.168.0.0/16 -d             172.18.0.0/16 -j LOG_DROP

    # Save the rules
    if command -v iptables-save &>/dev/null; then
        iptables-save > /etc/iptables/rules.v4
    elif command -v apt-get &>/dev/null; then
        apt-get update && apt-get install -y iptables-persistent
    else
        echo "Package manager not found. Please install iptables-persistent manually."
        exit 1
    fi

    echo "Firewall rules successfully set up!"
}

restart_ssh() {
    # Restart the SSH service to apply changes
    echo "Restarting SSH service... Bye bye!"
    systemctl restart sshd

    echo "SSH service restarted successfully! (You should probably not see this message)"
}

main() {
    echo "Starting home server setup..."

    echo "Disclaimer: This script assumes you are using Debian or a Debian-based distribution and Bash as your shell."

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

    echo "Do you want to setup firewall rules? (y/n)"
    read -r firewall_rules_answer
    if [[ "$firewall_rules_answer" == "y" ]]; then
        firewall_rules
    fi

    if [[ "$setup_ssh_answer" == "y" ]]; then
        restart_ssh
    fi

    echo "Home server setup completed successfully!"
}

# Main script execution
main()
