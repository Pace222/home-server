#!/bin/bash
set -e

### ASSUMPTIONS ###
# Docker containers in 172.16.0.0/12
# VPN container in 172.20.0.0/16
# Prod host in 192.168.2.0/24
# Dev host in 192.168.3.0/24
### ASSUMPTIONS ###

echo "Applying rules inside rootless Docker namespace"

nsenter -U --preserve-credentials --net --target $(cat $XDG_RUNTIME_DIR/docker.pid) bash -c '
    # Setup LOG_DROP chain
    iptables -N             LOG_DROP
    iptables -A             LOG_DROP                                                                                                         -j LOG --log-prefix "FW_DROP: "
    iptables -A             LOG_DROP                                                                                                         -j                         DROP

    iptables -N  DROP_IF_SRC_NOT_VPN
    iptables -A  DROP_IF_SRC_NOT_VPN  -s             172.20.0.0/16                                                                           -j                       RETURN
    iptables -A  DROP_IF_SRC_NOT_VPN  -s             172.16.0.0/12                                                                           -j                     LOG_DROP

    # Prevent containers from bypassing network boundaries by contacting a namespace IP
    iptables -A                INPUT  -s             172.16.0.0/12 -m addrtype --dst-type LOCAL                                              -j                     LOG_DROP
    iptables -A               OUTPUT  -s             172.16.0.0/12 -m addrtype --dst-type LOCAL                                              -j                     LOG_DROP
    iptables -A               OUTPUT  -m addrtype --src-type LOCAL -d             172.16.0.0/12                                              -j                     LOG_DROP
    iptables -A                INPUT  -m addrtype --src-type LOCAL -d             172.16.0.0/12                                              -j                     LOG_DROP

    # Prevent containers (except VPN) from bypassing network boundaries by contacting a host IP
    # But still accept connections from the host for ease of development
    iptables -A          DOCKER-USER                               -d            192.168.2.0/23 -m conntrack ! --ctstate ESTABLISHED,RELATED -j          DROP_IF_SRC_NOT_VPN
    iptables -A               OUTPUT                               -d            192.168.2.0/23 -m conntrack ! --ctstate ESTABLISHED,RELATED -j          DROP_IF_SRC_NOT_VPN
' && echo "Firewall rules successfully applied!" || echo "There was a problem setting firewall rules"
