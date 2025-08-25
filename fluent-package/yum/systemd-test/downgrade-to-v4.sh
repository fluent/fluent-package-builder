#!/bin/bash

set -exu

. $(dirname $0)/common.sh

install_v4

# Not auto started
(! systemctl status --no-pager td-agent)

# Start service to generate log
sudo systemctl enable --now td-agent
sudo systemctl stop td-agent

# Install the current
install_current
sudo systemctl daemon-reload
sudo systemctl enable --now fluentd
sudo systemctl stop fluentd

# Downgrade to v4
sudo $DNF remove -y fluent-package
# Symlinks are automatically removed
(! test -e /etc/td-agent)
(! test -e /var/log/td-agent)
(! test -e /etc/systemd/system/td-agent.service)
test -e /etc/fluent/td-agent.conf
test -h /etc/fluent/fluentd.conf.rpmsave
test $(readlink /etc/fluent/fluentd.conf.rpmsave) = "/etc/fluent/td-agent.conf"
# Manually prepare downgrading
sudo mkdir -p /var/log/td-agent
sudo chown td-agent:td-agent /var/log/td-agent
sudo mv /var/log/fluent/* /var/log/td-agent/
sudo rm -fr /var/log/fluent
# Downgrade by install v4 again
install_v4
sudo systemctl daemon-reload
sudo systemctl enable --now td-agent

# Test: service status
(! systemctl status --no-pager fluentd)
(systemctl status --no-pager td-agent)

# Test: config migration
test -d /etc/td-agent
test -e /etc/td-agent/td-agent.conf
(! test -h /etc/td-agent/fluentd.conf)
# /etc/fluent is untouched
test -e /etc/fluent/td-agent.conf
test -h /etc/fluent/fluentd.conf.rpmsave
test $(readlink /etc/fluent/fluentd.conf.rpmsave) = "/etc/fluent/td-agent.conf"

# Test: log file migration
test -d /var/log/td-agent
test -e /var/log/td-agent/td-agent.log
test -e /var/log/td-agent/fluentd.log

# Test: bin file migration
test -x /usr/sbin/td-agent
test -x /usr/sbin/td-agent-gem

# Test: environmental variables
pid=$(eval $(systemctl show td-agent --property=MainPID) && echo $MainPID)
env_vars=$(sudo sed -e 's/\x0/\n/g' /proc/$pid/environ)
test $(eval $env_vars && echo $HOME) = "/var/lib/td-agent"
test $(eval $env_vars && echo $LOGNAME) = "td-agent"
test $(eval $env_vars && echo $USER) = "td-agent"
test $(eval $env_vars && echo $FLUENT_CONF) = "/etc/td-agent/td-agent.conf"
test $(eval $env_vars && echo $TD_AGENT_LOG_FILE) = "/var/log/td-agent/td-agent.log"
test $(eval $env_vars && echo $FLUENT_PLUGIN) = "/etc/td-agent/plugin"
test $(eval $env_vars && echo $FLUENT_SOCKET) = "/var/run/td-agent/td-agent.sock"

# Test: No error logs
# (v4 default config outputs 'warn' log, so we should check only 'error' and 'fatal' logs)
sleep 3
test -e /var/log/td-agent/td-agent.log
(! grep -e '\[error\]' -e '\[fatal\]' /var/log/td-agent/td-agent.log)
