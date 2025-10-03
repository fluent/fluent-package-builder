#!/bin/bash

set -exu

. $(dirname $0)/commonvar.sh

# Display unit info for debug
sudo systemctl cat systemd-tmpfiles-clean.service
sudo systemctl cat systemd-tmpfiles-clean.timer

# Install the built package
sudo $DNF install -y \
    /host/${distribution}/${DISTRIBUTION_VERSION}/x86_64/Packages/fluent-package-[0-9]*.rpm

# Wait all processes to start
(! systemctl status --no-pager fluentd)
sudo systemctl enable --now fluentd
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
