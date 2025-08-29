#!/bin/bash

set -exu

. $(dirname $0)/common.sh

install_v5_lts
sudo systemctl enable --now fluentd
systemctl status --no-pager fluentd
systemctl status --no-pager td-agent
main_pid=$(eval $(systemctl show fluentd --property=MainPID) && echo $MainPID)

# Install without stopping the service to test automatic restart after update.
case $1 in
  local)
    install_current
    ;;
  v6)
    install_v6
    ;;
  lts)
    install_v6_lts
    ;;
esac

# Test: take over enabled state
systemctl is-enabled fluentd

# It might take some time to restart
sleep 3

# Test: service status
systemctl status --no-pager fluentd
systemctl status --no-pager td-agent

# Fluentd should be restarted when update from v5 LTS.
test $main_pid -ne $(eval $(systemctl show fluentd --property=MainPID) && echo $MainPID)

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
# (v5 default config outputs 'warn' log, so we should check only 'error' and 'fatal' logs)
sleep 3
test -e /var/log/fluent/fluentd.log
(! grep -e '\[error\]' -e '\[fatal\]' /var/log/fluent/fluentd.log)

# Test: Guard duplicated instance
(! sudo /usr/sbin/fluentd)
(! sudo /usr/sbin/fluentd -v)
sudo /usr/sbin/fluentd --dry-run

# Uninstall
sudo $DNF remove -y fluent-package
sudo systemctl daemon-reload

getent passwd fluentd >/dev/null
getent group fluentd >/dev/null

# `sudo systemctl daemon-reload` clears the service completely.
#   (The result of `systemctl status` will be `unfound`)
# Note: RPM does not leave links like `@/etc/systemd/system/fluentd.service`.
#   (Different from deb)

(! systemctl status --no-pager td-agent)
(! systemctl status --no-pager fluentd)
