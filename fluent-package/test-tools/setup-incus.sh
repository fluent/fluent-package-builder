#!/bin/bash

sudo apt update
sudo apt install -y -V incus

# Allow egress network traffic flows for Incus
# https://linuxcontainers.org/incus/docs/main/howto/network_bridge_firewalld/#prevent-connectivity-issues-with-incus-and-docker
sudo iptables -I DOCKER-USER -i incusbr0 -j ACCEPT
sudo iptables -I DOCKER-USER -o incusbr0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
sudo incus admin init --auto

# Enable custom incus images
sudo incus remote add fluent https://fluentd.cdn.cncf.io/test/incus-images --accept-certificate --protocol=simplestreams
