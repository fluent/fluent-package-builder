#!/bin/bash

set -exu

. $(dirname $0)/common.sh

# Display unit info for debug
sudo systemctl cat systemd-tmpfiles-clean.service
sudo systemctl cat systemd-tmpfiles-clean.timer

# Install the built package
install_current

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
