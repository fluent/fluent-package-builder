#!/bin/bash

set -exu

. $(dirname $0)/common.sh

if [ "$distribution" = "amazon" ]; then
    sudo $DNF repolist -v
    sudo $DNF --releasever=latest update -y
fi

service_restart=$1
status_before_update=$2 # active / inactive

install_current

sudo systemctl enable fluentd

if [ "$status_before_update" = active ]; then
    sudo systemctl start fluentd
    main_pid=$(eval $(systemctl show fluentd --property=MainPID) && echo $MainPID)
fi

# Set FLUENT_PACKAGE_SERVICE_RESTART
sudo sed -i "s/=auto/=$service_restart/" /etc/sysconfig/fluentd

# Install plugin manually (plugin and gem)
sudo /opt/fluent/bin/fluent-gem install --no-document fluent-plugin-concat
sudo /opt/fluent/bin/fluent-gem install --no-document gqtp

# Show bundled ruby version before updating to next major version
/opt/fluent/bin/ruby -v

# Install next major version
package="/host/v7-test/${distribution}/${DISTRIBUTION_VERSION}/x86_64/Packages/fluent-package-*.rpm"
sudo $DNF install -y $package

# Show bundled ruby version
/opt/fluent/bin/ruby -v

# Test: The service should take over the state
systemctl is-enabled fluentd

if [ "$status_before_update" = inactive ]; then
    # Test: The service should NOT start automatically
    (! systemctl is-active fluentd)
    # Test: Plugin gem should not be installed automatically
    (! /opt/fluent/bin/fluent-gem list | grep fluent-plugin-concat)
else
    # Test: The process before update should continue to run
    systemctl is-active fluentd
    test $main_pid -eq $(eval $(systemctl show fluentd --property=MainPID) && echo $MainPID)

    sleep 15

    if [ "$service_restart" = manual ]; then
        # Test: Plugin gem should not be installed automatically
        (! /opt/fluent/bin/fluent-gem list | grep fluent-plugin-concat)
        # Test: Main process should NOT be replaced until USR2 signal fired
        test $main_pid  -eq $(eval $(systemctl show fluentd --property=MainPID) && echo $MainPID)

        sudo kill -USR2 $main_pid
        sleep 15

        # Test: Main process should be replaced by USR2 signal
        test $main_pid -ne $(eval $(systemctl show fluentd --property=MainPID) && echo $MainPID)
    else
        # Test: Plugin gem should be installed automatically
        /opt/fluent/bin/fluent-gem list | grep fluent-plugin-concat
        # Test: Non fluent-plugin- prefix gem should not be installed automatically
        (! /opt/fluent/bin/fluent-gem list | grep gqtp)
        # Test: Main process should be replaced automatically
        test $main_pid -ne $(eval $(systemctl show fluentd --property=MainPID) && echo $MainPID)
    fi
fi

# Ensure the service is started
sudo systemctl start fluentd

# Test: migration process from v4 must not be done
(! test -e /etc/td-agent)
(! test -e /etc/fluent/td-agent.conf)
(! test -e /var/log/td-agent)
(! test -e /var/log/fluent/td-agent.log)
(! test -h /usr/sbin/td-agent)
(! test -h /usr/sbin/td-agent-gem)

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

# Test: logs
sleep 3
test -e /var/log/fluent/fluentd.log
(! grep -e '\[warn\]' -e '\[error\]' -e '\[fatal\]' /var/log/fluent/fluentd.log)

# Uninstall
sudo $DNF remove -y fluent-package
sudo systemctl daemon-reload

(! getent passwd td-agent >/dev/null)
(! getent group td-agent >/dev/null)
getent passwd fluentd >/dev/null
getent group fluentd >/dev/null

# `sudo systemctl daemon-reload` clears the service completely.
#   (The result of `systemctl status` will be `unfound`)
# Note: RPM does not leave links like `@/etc/systemd/system/fluentd.service`.
#   (Different from deb)

(! systemctl status --no-pager fluentd)
