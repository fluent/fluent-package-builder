#!/bin/bash

set -exu

. $(dirname $0)/common.sh

# Display unit info for debug
sudo systemctl cat systemd-tmpfiles-clean.service
sudo systemctl cat systemd-tmpfiles-clean.timer

# Install next major version
package="/host/v7-test/${distribution}/${DISTRIBUTION_VERSION}/x86_64/Packages/fluent-package-*.rpm"
sudo $DNF install -y $package

sudo systemctl enable --now fluentd
systemctl status --no-pager fluentd
main_pid=$(eval $(systemctl show fluentd --property=MainPID) && echo $MainPID)
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
case "$distribution" in
amazon)
    curl -O https://fluentd.cdn.cncf.io/lts/6/amazon/2023/x86_64/fluent-package-6.0.0-1.amzn2023.x86_64.rpm
    sudo $DNF install -y fluent-package-6.0.0-1.amzn2023.x86_64.rpm
    ;;
*)
    curl -O https://fluentd.cdn.cncf.io/lts/6/redhat/${DISTRIBUTION_VERSION}/x86_64/fluent-package-6.0.0-1.el${DISTRIBUTION_VERSION}.x86_64.rpm
    sudo $DNF install -y fluent-package-6.0.0-1.el${DISTRIBUTION_VERSION}.x86_64.rpm
    ;;
esac

systemctl status --no-pager fluentd
systemctl status --no-pager td-agent

test $main_pid -eq $(eval $(systemctl show fluentd --property=MainPID) && echo $MainPID)
