#!/bin/bash

set -exu

. $(dirname $0)/../commonvar.sh

# Install v4
sudo apt clean all
apt_source_package=/vagrant/${distribution}/pool/${code_name}/${channel}/*/*/fluentd-apt-source*_all.deb
sudo apt install -V -y ${apt_source_package} ca-certificates
sudo apt update
sudo apt install -V -y td-agent=4.5.0-1

systemctl status --no-pager td-agent

# Install the current
sudo apt install -V -y \
    /vagrant/${distribution}/pool/${code_name}/${channel}/*/*/fluent-package_*_${architecture}.deb

# Test: service status
systemctl status --no-pager fluentd
test $(systemctl status --no-pager td-agent > /dev/null 2>&1; echo $?;) -eq 3

# TODO: There are some tests being commented out. They will be supported by future fixes.

# Test: restoring td-agent service alias
# sudo systemctl unmask td-agent
# sudo systemctl enable fluentd
# systemctl status --no-pager td-agent
# systemctl status --no-pager fluentd

# Test: config migration
# test -L /etc/td-agent
# test -e /etc/td-agent/td-agent.conf

# Test: log file migration
# test -L /var/log/td-agent
# test -e /var/log/td-agent/td-agent.log

# Test: environmental variables
pid=$(systemctl show fluentd --property=MainPID --value)
env_vars=$(sudo sed -e 's/\x0/\n/g' /proc/$pid/environ)
test $(eval $env_vars && echo $LOGNAME) = "_fluentd"
test $(eval $env_vars && echo $USER) = "_fluentd"
# test $(eval $env_vars && echo $FLUENT_CONF) = "/etc/fluent/td-agent.conf"
# test $(eval $env_vars && echo $FLUENT_PLUGIN) = "/etc/fluent/plugin"
# test $(eval $env_vars && echo $TD_AGENT_LOG_FILE) = "/var/log/fluent/td-agent.log"

# Uninstall
sudo apt remove -y fluent-package
! systemctl status --no-pager td-agent
! systemctl status --no-pager fluentd
