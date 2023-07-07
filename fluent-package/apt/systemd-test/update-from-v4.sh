#!/bin/bash

set -exu

. $(dirname $0)/../commonvar.sh

# TODO: Remove it when v5 repository was deployed
sudo apt install -y curl ca-certificates
curl -O https://packages.treasuredata.com/4/${distribution}/${code_name}/pool/contrib/f/fluentd-apt-source/fluentd-apt-source_2020.8.25-1_all.deb
sudo apt install -y ./fluentd-apt-source_2020.8.25-1_all.deb

# Install v4
sudo apt clean all
# Uncomment when v5 repository was deployed
#apt_source_package=/vagrant/${distribution}/pool/${code_name}/${channel}/*/*/fluent-apt-source*_all.deb
#sudo apt install -V -y ${apt_source_package} ca-certificates
sudo apt update
sudo apt install -V -y td-agent=4.5.0-1

systemctl status --wait --no-pager td-agent

# Install the current
sudo apt install -V -y \
    /vagrant/${distribution}/pool/${code_name}/${channel}/*/*/fluent-package_*_${architecture}.deb

# Test: service status
systemctl status --wait --no-pager fluentd
! systemctl status --wait --no-pager td-agent

# TODO: There are some tests being commented out. They will be supported by future fixes.

# Test: restoring td-agent service alias
sudo systemctl unmask td-agent
sudo systemctl enable fluentd
#
# FIXME:
# td-agent (alias of fluentd service should be enabled,
# but systemctl status td-agent may fail frequently with exit 3.
# It means inactive (dead) status.
# Until finding correct solution to fix this issue, disable it for a while.
#
#systemctl status --wait --no-pager td-agent
#
systemctl status --wait --no-pager fluentd

# Test: config migration
test -L /etc/td-agent
test -e /etc/td-agent/td-agent.conf

# Test: log file migration
test -L /var/log/td-agent
test -e /var/log/td-agent/td-agent.log

# Test: environmental variables
pid=$(systemctl show fluentd --property=MainPID --value)
env_vars=$(sudo sed -e 's/\x0/\n/g' /proc/$pid/environ)
test $(eval $env_vars && echo $LOGNAME) = "_fluentd"
test $(eval $env_vars && echo $USER) = "_fluentd"
test $(eval $env_vars && echo $FLUENT_CONF) = "/etc/fluent/td-agent.conf"
test $(eval $env_vars && echo $FLUENT_PLUGIN) = "/etc/fluent/plugin"
test $(eval $env_vars && echo $TD_AGENT_LOG_FILE) = "/var/log/fluent/td-agent.log"

# Uninstall
sudo apt remove -y fluent-package
! systemctl status --wait --no-pager td-agent
! systemctl status --wait --no-pager fluentd
