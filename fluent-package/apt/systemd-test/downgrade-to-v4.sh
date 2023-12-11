#!/bin/bash

set -exu

. $(dirname $0)/../commonvar.sh

# Install v4
sudo apt install -y curl ca-certificates
curl -fsSL https://toolbelt.treasuredata.com/sh/install-${distribution}-${code_name}-td-agent4.sh | sh

# td-agent is running
systemctl status --no-pager td-agent

# fluent-package 5 (LTS)
#curl -fsSL https://toolbelt.treasuredata.com/sh/install-${distribution}-${code_name}-fluent-package5-lts.sh | sh
#sudo apt purge -y fluent-lts-apt-source

# Ensure to install the current
sudo apt install -V -y \
    /host/${distribution}/pool/${code_name}/${channel}/*/*/fluent-package_*_${architecture}.deb

# td-agent.service is already masked (link to /dev/null), and remove td-agent.service alias not to conflict with v4
sudo systemctl unmask td-agent

# Even though removing fluent-package, log and .conf are kept. dpkg reports "rc fluent-package" and "rc td-agent" status.
sudo apt remove -y fluent-package

# fluentd.service is already masked (link to /dev/null), then remove it.
sudo systemctl unmask fluentd

# Drop symbolic links and recreate real directory.
sudo rm -f /var/log/td-agent
sudo rm -f /etc/td-agent

# Migrate logs
sudo mkdir -p /var/log/td-agent
sudo chown td-agent:td-agent /var/log/td-agent
sudo mv /var/log/fluent/* /var/log/td-agent/
sudo rm -fr /var/log/fluent

# Reinstall v4, but /etc/td-agent is empty.
sudo mkdir -p /etc/td-agent
sudo chown td-agent:td-agent /etc/td-agent
sudo mv /etc/fluent/td-agent.conf /etc/td-agent/
curl -fsSL https://toolbelt.treasuredata.com/sh/install-${distribution}-${code_name}-td-agent4.sh | sh

# Test: service status
(! systemctl status --no-pager fluentd)
(systemctl status --no-pager td-agent)

# Test: config migration
test -d /etc/td-agent
test -e /etc/td-agent/td-agent.conf
(! test -h /etc/td-agent/fluentd.conf)

# Test: log file migration
test -d /var/log/td-agent
test -e /var/log/td-agent/td-agent.log

# Test: bin file migration
test -x /usr/sbin/td-agent
test -x /usr/sbin/td-agent-gem

# Test: environmental variables
pid=$(systemctl show td-agent --property=MainPID --value)
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
