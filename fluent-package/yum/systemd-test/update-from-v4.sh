#!/bin/bash

set -exu

. $(dirname $0)/commonvar.sh

# Install v4
sudo rpm --import https://packages.treasuredata.com/GPG-KEY-td-agent
case ${distribution} in
    amazon)
        cat > td.repo <<'EOF';
[treasuredata]
name=TreasureData
baseurl=https://packages.treasuredata.com/4/amazon/$releasever/$basearch
gpgcheck=1
gpgkey=https://packages.treasuredata.com/GPG-KEY-td-agent
EOF
        sudo mv td.repo /etc/yum.repos.d/
        ;;
    *)
        cat > td.repo <<'EOF';
[treasuredata]
name=TreasureData
baseurl=https://packages.treasuredata.com/4/redhat/$releasever/$basearch
gpgcheck=1
gpgkey=https://packages.treasuredata.com/GPG-KEY-td-agent
EOF
        sudo mv td.repo /etc/yum.repos.d/
        ;;
esac
sudo $DNF update -y
sudo $DNF install -y td-agent-${td_agent_version}-1.*.x86_64

sudo systemctl enable --now td-agent
systemctl status --no-pager td-agent

# Install the current
sudo $DNF install -y \
    /vagrant/${distribution}/${DISTRIBUTION_VERSION}/x86_64/Packages/fluent-package-[0-9]*.rpm

# Test: service status
systemctl status --no-pager fluentd # Migration process starts the service automatically
sudo systemctl enable --now fluentd
systemctl status --no-pager td-agent

# Test: config migration
test -h /etc/td-agent
test -h /etc/fluent/fluentd.conf
test $(readlink "/etc/fluent/fluentd.conf") = "/etc/fluent/td-agent.conf"
test -e /etc/td-agent/td-agent.conf

# Test: log file migration
test -h /var/log/td-agent
test -e /var/log/td-agent/td-agent.log

# Test: bin file migration
test -h /usr/sbin/td-agent
test -h /usr/sbin/td-agent-gem

# Test: environmental variables
pid=$(eval $(systemctl show fluentd --property=MainPID) && echo $MainPID)
env_vars=$(sudo sed -e 's/\x0/\n/g' /proc/$pid/environ)
test $(eval $env_vars && echo $HOME) = "/var/lib/fluent"
test $(eval $env_vars && echo $LOGNAME) = "fluentd"
test $(eval $env_vars && echo $USER) = "fluentd"
test $(eval $env_vars && echo $FLUENT_CONF) = "/etc/fluent/fluentd.conf"
test $(eval $env_vars && echo $FLUENT_PACKAGE_LOG_FILE) = "/var/log/fluent/fluentd.log"
test $(eval $env_vars && echo $FLUENT_PLUGIN) = "/etc/fluent/plugin"
test $(eval $env_vars && echo $FLUENT_SOCKET) = "/var/run/fluent/fluentd.sock"

# Test: No error logs
# (v4 default config outputs 'warn' log, so we should check only 'error' and 'fatal' logs)
sleep 3
test -e /var/log/fluent/fluentd.log
(! grep -e '\[error\]' -e '\[fatal\]' /var/log/fluent/fluentd.log)

# Uninstall
sudo $DNF remove -y fluent-package
sudo systemctl daemon-reload

# `sudo systemctl daemon-reload` clears the service completely.
#   (The result of `systemctl status` will be `unfound`)
# Note: RPM does not leave links like `@/etc/systemd/system/fluentd.service`.
#   (Different from deb)

(! systemctl status --no-pager td-agent)
(! systemctl status --no-pager fluentd)
