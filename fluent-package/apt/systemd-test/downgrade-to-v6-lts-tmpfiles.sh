#!/bin/bash

set -exu

. $(dirname $0)/../commonvar.sh

# Install next major version
sudo apt install -V -y \
    /host/v7-test/${distribution}/pool/${code_name}/${channel}/*/*/fluent-package_*_${architecture}.deb

systemctl status --no-pager fluentd
systemctl status --no-pager td-agent
main_pid=$(eval $(systemctl show td-agent --property=MainPID) && echo $MainPID)
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

# Downgrade to v6.0.0
curl -O https://fluentd.cdn.cncf.io/lts/6/${distribution}/${code_name}/pool/contrib/f/fluent-package/fluent-package_6.0.0-1_amd64.deb
sudo apt install -V -y --allow-downgrades fluent-package_6.0.0-1_amd64.deb

systemctl status --no-pager fluentd
systemctl status --no-pager td-agent

test $main_pid -eq $(eval $(systemctl show fluentd --property=MainPID) && echo $MainPID)
