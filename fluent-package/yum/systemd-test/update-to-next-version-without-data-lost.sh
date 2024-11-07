#!/bin/bash

set -exu

. $(dirname $0)/commonvar.sh

sudo $DNF install -y rsyslog

# Install the current
package="/host/${distribution}/${DISTRIBUTION_VERSION}/x86_64/Packages/fluent-package-[0-9]*.rpm"
sudo $DNF install -y $package

# Set up configuration
cat < $(dirname $0)/../../test-tools/rsyslog.conf >> /etc/rsyslog.conf
cp $(dirname $0)/../../test-tools/fluentd.conf /etc/fluent/fluentd.conf

# Launch rsyslog
sudo systemctl restart rsyslog

# Launch fluentd
sudo systemctl enable --now fluentd
main_pid=$(eval $(systemctl show fluentd --property=MainPID) && echo $MainPID)

# Ensure to wait for fluentd launching
sleep 1

# Send logs in background for 4 seconds
/opt/fluent/bin/ruby $(dirname $0)/../../test-tools/logdata-sender.rb \
    --udp-data-count 50 --tcp-data-count 60 --syslog-data-count 70 --syslog-identifer "test-syslog" --duration 4 &

sleep 1

# Update to the next major version
next_package="/host/v6-test/${distribution}/${DISTRIBUTION_VERSION}/x86_64/Packages/fluent-package-*.rpm"
sudo $DNF install -y $next_package
test $main_pid -eq $(eval $(systemctl show fluentd --property=MainPID) && echo $MainPID)

sleep 3

# Stop fluentd to flush the logs and check
systemctl stop fluentd
test $(wc -l /var/log/fluent/test_udp*.log | cut -d' ' -f 1) = "50"
test $(wc -l /var/log/fluent/test_tcp*.log | cut -d' ' -f 1) = "60"
test $(grep "test-syslog" /var/log/fluent/test_syslog*.log | wc -l) = "70"
