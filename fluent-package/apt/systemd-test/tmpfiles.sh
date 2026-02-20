#!/bin/bash

set -exu

. $(dirname $0)/../commonvar.sh

# Display unit info for debug
sudo systemctl cat systemd-tmpfiles-clean.service
sudo systemctl cat systemd-tmpfiles-clean.timer

# Install the built package
sudo apt install -V -y \
    /host/${distribution}/pool/${code_name}/${channel}/*/*/fluent-package_*_${architecture}.deb

# Wait all processes to start
systemctl status --no-pager fluentd
sleep 3

# Test: the files under /tmp/ exist and not be cleaned up by default
ls -d /tmp/fluent
ls -d /tmp/fluentd-lock-*
sudo systemd-tmpfiles --clean
ls -d /tmp/fluent
ls -d /tmp/fluentd-lock-*

# Make timestamps old
touch -d "2 months ago" /tmp/fluentd
touch -d "2 months ago" /tmp/fluentd-lock-*

# Test: the files under /tmp/ not be cleaned up even if they are old
sudo systemd-tmpfiles --clean
ls -d /tmp/fluent
ls -d /tmp/fluentd-lock-*

# The update should succeed even if the working directory does not exist
# https://github.com/fluent/fluent-package-builder/pull/955
systemctl stop fluentd
rm -rf /tmp/fluent/

# Install next major version
sudo apt install -V -y \
    /host/v7-test/${distribution}/pool/${code_name}/${channel}/*/*/fluent-package_*_${architecture}.deb 2>&1 | tee upgrade.log
