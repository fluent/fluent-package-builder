#!/bin/bash

set -exu

. $(dirname $0)/commonvar.sh

install_v4
sudo systemctl enable --now td-agent
systemctl status --no-pager td-agent
main_pid=$(eval $(systemctl show td-agent --property=MainPID) && echo $MainPID)

# Generate garbage files
sudo touch /etc/td-agent/a\ b\ c
sudo touch /var/log/td-agent/a\ b\ c.log
sudo touch /etc/td-agent/plugin/in_fake.rb
for d in $(seq 1 10); do
    sudo touch /var/log/td-agent/$d.log
done

install_current

# Test: take over enabled state
systemctl is-enabled fluentd

# Test: service status
systemctl status --no-pager fluentd # Migration process starts the service automatically
sudo systemctl enable fluentd # Enable the unit name alias
systemctl status --no-pager td-agent

# Fluentd should be restarted when update from v4.
test $main_pid -ne $(eval $(systemctl show fluentd --property=MainPID) && echo $MainPID)

# Test: config migration
test -h /etc/td-agent
test -h /etc/fluent/fluentd.conf
test $(readlink "/etc/fluent/fluentd.conf") = "/etc/fluent/td-agent.conf"
test -e /etc/td-agent/td-agent.conf
test -e /etc/fluent/a\ b\ c
test -e /etc/fluent/plugin/in_fake.rb

# Test: log file migration
test -h /var/log/td-agent
test -e /var/log/td-agent/td-agent.log
test -e /var/log/fluent/a\ b\ c.log
for d in $(seq 1 10); do
    test -e /var/log/fluent/$d.log
done

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

# Test: fluent-diagtool
sudo fluent-gem install fluent-plugin-concat
sudo /opt/fluent/bin/fluent-diagtool -t fluentd -o /tmp
test $(find /tmp/ -name gem_local_list.output | xargs cat) = "fluent-plugin-concat"

# Test: Guard duplicated instance
(! sudo /usr/sbin/fluentd)
(! sudo /usr/sbin/td-agent)
(! sudo /usr/sbin/fluentd -v)
sudo /usr/sbin/fluentd --dry-run

# Uninstall
sudo $DNF remove -y fluent-package
sudo systemctl daemon-reload

getent passwd td-agent >/dev/null
getent group td-agent >/dev/null
getent passwd fluentd >/dev/null
getent group fluentd >/dev/null

# `sudo systemctl daemon-reload` clears the service completely.
#   (The result of `systemctl status` will be `unfound`)
# Note: RPM does not leave links like `@/etc/systemd/system/fluentd.service`.
#   (Different from deb)

(! systemctl status --no-pager td-agent)
(! systemctl status --no-pager fluentd)
