#!/bin/bash

set -exu

. $(dirname $0)/../commonvar.sh

# Install the current
sudo apt install -V -y \
    /vagrant/${distribution}/pool/${code_name}/${channel}/*/*/fluent-package_*_${architecture}.deb

# Make a dummy pacakge for the next version
dpkg-deb -R /vagrant/${distribution}/pool/${code_name}/${channel}/*/*/fluent-package_*_${architecture}.deb tmp
last_ver=$(cat tmp/DEBIAN/control | grep "Version: " | sed -E "s/Version: ([0-9.]+)-([0-9]+)/\2/g")
sed -i -E "s/Version: ([0-9.]+)-([0-9]+)/Version: \1-$(($last_ver+1))/g" tmp/DEBIAN/control
dpkg-deb --build tmp next_version.deb

# Install the dummy package
sudo apt install -V -y ./next_version.deb

# Test: service
systemctl status --no-pager fluentd

# Test: migration process from v4 must not be done
! test -e /etc/td-agent
! test -e /etc/fluent/td-agent.conf
! test -e /var/log/td-agent
! test -e /var/log/fluent/td-agent.log

# Test: environmental variables
# TODO: There are some tests being commented out. They will be supported by future fixes.
pid=$(systemctl show fluentd --property=MainPID --value)
env_vars=$(sudo sed -e 's/\x0/\n/g' /proc/$pid/environ)
test $(eval $env_vars && echo $LOGNAME) = "_fluentd"
test $(eval $env_vars && echo $USER) = "_fluentd"
# test $(eval $env_vars && echo $FLUENT_CONF) = "/etc/fluent/fluentd.conf"
# test $(eval $env_vars && echo $FLUENT_PLUGIN) = "/etc/fluent/plugin"
# test $(eval $env_vars && echo $TD_AGENT_LOG_FILE) = "/var/log/fluent/fluentd.log"

# Uninstall
sudo apt remove -y fluent-package
! systemctl status --no-pager td-agent
! systemctl status --no-pager fluentd
