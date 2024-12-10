#!/bin/bash

set -exu

. $(dirname $0)/../commonvar.sh


# If it update from v5 LTS without stopping Fluentd, Fluentd will not be restarted.
# Install v5 LTS
curl --fail --silent --show-error --location https://toolbelt.treasuredata.com/sh/install-${distribution}-${code_name}-fluent-package5-lts.sh | sh

systemctl status --no-pager fluentd
systemctl status --no-pager td-agent
main_pid=$(eval $(systemctl show td-agent --property=MainPID) && echo $MainPID)

# Install the current
sudo apt install -V -y \
    /host/${distribution}/pool/${code_name}/${channel}/*/*/fluent-package_*_${architecture}.deb

# Test: service status
systemctl status --no-pager fluentd
systemctl status --no-pager td-agent

# Fluentd should NOT be restarted.
test $main_pid -eq $(eval $(systemctl show fluentd --property=MainPID) && echo $MainPID)

apt purge -y fluent-package

# If it update from v5 LTS with stopping Fluentd, Fluentd will be started when service is enabled.
# Install v5 LTS
curl --fail --silent --show-error --location https://toolbelt.treasuredata.com/sh/install-${distribution}-${code_name}-fluent-package5-lts.sh | sh

systemctl status --no-pager fluentd
systemctl status --no-pager td-agent
main_pid=$(eval $(systemctl show td-agent --property=MainPID) && echo $MainPID)

systemctl stop fluentd

# Install the current
sudo apt install -V -y \
    /host/${distribution}/pool/${code_name}/${channel}/*/*/fluent-package_*_${architecture}.deb

systemctl status --no-pager fluentd
systemctl status --no-pager td-agent

# Fluentd should be started if service was stopped before update.
test $main_pid -ne $(eval $(systemctl show fluentd --property=MainPID) && echo $MainPID)

# Test: environmental variables
pid=$(systemctl show fluentd --property=MainPID --value)
env_vars=$(sudo sed -e 's/\x0/\n/g' /proc/$pid/environ)
test $(eval $env_vars && echo $HOME) = "/var/lib/fluent"
test $(eval $env_vars && echo $LOGNAME) = "_fluentd"
test $(eval $env_vars && echo $USER) = "_fluentd"
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
