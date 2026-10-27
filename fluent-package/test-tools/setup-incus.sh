#!/bin/bash

sudo apt update
sudo apt install -y -V incus

# Allow egress network traffic flows for Incus
# https://linuxcontainers.org/incus/docs/main/howto/network_bridge_firewalld/#prevent-connectivity-issues-with-incus-and-docker
sudo iptables -I DOCKER-USER -i incusbr0 -j ACCEPT
sudo iptables -I DOCKER-USER -o incusbr0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
sudo incus admin init --auto
sudo incus profile set default raw.apparmor="signal peer=@{profile_name}//&unconfined,
ptrace peer=@{profile_name}//&unconfined,"
if [ -f /etc/apparmor.d/usr.sbin.rsyslogd ]; then
  sudo apparmor_parser -R /etc/apparmor.d/usr.sbin.rsyslogd
else
  echo "::warning::/etc/apparmor.d/usr.sbin.rsyslogd is not found. Skip unloading the host rsyslogd AppArmor profile."
fi
# enable incus legacy/snapshot images
sudo incus remote add fluent https://fluentd.cdn.cncf.io/test/incus-images --accept-certificate --protocol=simplestreams
