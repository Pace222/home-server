#!/bin/bash
set -e

DOCKER_NETWORK="172.16.0.0/12"
VPN_DOCKER_NETWORK="172.20.0.0/16"
HOST_NETWORK="10.30.0.0/16"

echo "Applying rules inside rootless Docker namespace"

nsenter -U --preserve-credentials --net --target $(cat $XDG_RUNTIME_DIR/docker.pid) bash -c "
    # Setup LOG_DROP chain
    iptables -N             LOG_DROP
    iptables -A             LOG_DROP                                                                                                         -j LOG --log-prefix \"FW_DROP: \"
    iptables -A             LOG_DROP                                                                                                         -j                           DROP

    iptables -N  DROP_IF_SRC_NOT_VPN
    iptables -A  DROP_IF_SRC_NOT_VPN  -s       $VPN_DOCKER_NETWORK                                                                           -j                         RETURN
    iptables -A  DROP_IF_SRC_NOT_VPN  -s           $DOCKER_NETWORK                                                                           -j                       LOG_DROP

    # Prevent containers from bypassing network boundaries by contacting a namespace IP
    iptables -A                INPUT  -s           $DOCKER_NETWORK -m addrtype --dst-type LOCAL                                              -j                       LOG_DROP
    iptables -A               OUTPUT  -m addrtype --src-type LOCAL -d           $DOCKER_NETWORK                                              -j                       LOG_DROP

    # Prevent containers (except VPN) from bypassing network boundaries by contacting a host IP
    # But still accept connections from the host for ease of development
    iptables -A          DOCKER-USER                               -d             $HOST_NETWORK -m conntrack ! --ctstate ESTABLISHED,RELATED -j            DROP_IF_SRC_NOT_VPN
" && echo "Firewall rules successfully applied!" || echo "There was a problem setting firewall rules"
