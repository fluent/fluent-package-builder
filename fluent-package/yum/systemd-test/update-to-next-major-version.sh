#!/bin/bash

set -exu

. $(dirname $0)/commonvar.sh

service_restart=$1
status_before_update=$2 # active / inactive

# Install the current
package="/host/${distribution}/${DISTRIBUTION_VERSION}/x86_64/Packages/fluent-package-*.rpm"
sudo $DNF install -y $package

if [ "$status_before_update" = active ]; then
    sudo systemctl start fluentd
fi

# Set FLUENT_PACKAGE_SERVICE_RESTART
sed -i "s/=auto/=$service_restart/" /etc/sysconfig/fluentd

# Install plugin manually (plugin and gem)
sudo /opt/fluent/bin/fluent-gem install --no-document fluent-plugin-concat
sudo /opt/fluent/bin/fluent-gem install --no-document gqtp

# Install next major version
package="/host/v6-test/${distribution}/${DISTRIBUTION_VERSION}/x86_64/Packages/fluent-package-*.rpm"
sudo $DNF install -y $package

# Test: Check whether plugin/gem were installed during upgrading
if [ "$service_restart" != manual ] && [ "$status_before_update" = active ]; then
    # plugin gem should be installed automatically
    /opt/fluent/bin/fluent-gem list | grep fluent-plugin-concat
    # Non fluent-plugin- prefix gem should not be installed automatically
    (! /opt/fluent/bin/fluent-gem list | grep gqtp)
else
    # plugin gem should not be installed automatically
    (! /opt/fluent/bin/fluent-gem list | grep fluent-plugin-concat)
fi
