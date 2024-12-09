#!/bin/bash

set -exu

. $(dirname $0)/../commonvar.sh

service_restart=$1

# Install the current
sudo apt install -V -y \
    /host/${distribution}/pool/${code_name}/${channel}/*/*/fluent-package_*_${architecture}.deb

# Set FLUENT_PACKAGE_SERVICE_RESTART
sed -i "s/=auto/=$service_restart/" /etc/default/fluentd

# Install plugin manually (plugin and gem)
sudo /opt/fluent/bin/fluent-gem install --no-document fluent-plugin-concat
sudo /opt/fluent/bin/fluent-gem install --no-document gqtp

# Install next major version
sudo apt install -V -y \
    /host/v6-test/${distribution}/pool/${code_name}/${channel}/*/*/fluent-package_*_${architecture}.deb 2>&1 | tee upgrade.log

# Test: needrestart was suppressed
if dpkg-query --show --showformat='${Version}' needrestart ; then
  case $code_name in
    focal)
      # dpkg-query succeeds even though needrestart is not installed.
      (! grep "No services need to be restarted." upgrade.log)
      ;;
    *)
      grep "No services need to be restarted." upgrade.log
      ;;
  esac
fi

# Test: Check whether plugin/gem were installed during upgrading
if [ "$service_restart" = auto ]; then
    # plugin gem should be installed automatically
    /opt/fluent/bin/fluent-gem list | grep fluent-plugin-concat
    # Non fluent-plugin- prefix gem should not be installed automatically
    (! /opt/fluent/bin/fluent-gem list | grep gqtp)
else
    # plugin gem should not be installed automatically
    (! /opt/fluent/bin/fluent-gem list | grep fluent-plugin-concat)
fi

