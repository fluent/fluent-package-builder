#!/bin/bash

set -exu

. $(dirname $0)/../commonvar.sh

# Install the current
sudo apt install -V -y \
    /host/${distribution}/pool/${code_name}/${channel}/*/*/fluent-package_*_${architecture}.deb

# Install plugin manually (plugin and gem)
sudo /opt/fluent/bin/fluent-gem install --no-document fluent-plugin-concat
sudo /opt/fluent/bin/fluent-gem install --no-document gqtp

# Install next major version
sudo apt install -V -y \
    /host/v6-test/${distribution}/pool/${code_name}/${channel}/*/*/fluent-package_*_${architecture}.deb

# Test: Check whether plugin/gem were installed during upgrading
/opt/fluent/bin/fluent-gem list | grep fluent-plugin-concat
# Non fluent-plugin- prefix gem should not be installed automatically
(! /opt/fluent/bin/fluent-gem list | grep gqtp)
