#!/bin/bash

set -exu

. $(dirname $0)/../commonvar.sh

sudo apt install -V -y rsyslog

# Install the current
sudo apt install -V -y \
    /host/${distribution}/pool/${code_name}/${channel}/*/*/fluent-package_*_${architecture}.deb

# Set up configuration
cat < $(dirname $0)/../../test-tools/rsyslog.conf >> /etc/rsyslog.conf
cp $(dirname $0)/../../test-tools/fluentd.conf /etc/fluent/fluentd.conf

# Launch rsyslog
sudo systemctl restart rsyslog

# Launch fluentd
sudo systemctl restart fluentd
main_pid=$(systemctl show --value --property=MainPID fluentd)

# Ensure to wait for fluentd launching
sleep 1

# Send logs in background for 4 seconds
/opt/fluent/bin/ruby $(dirname $0)/../../test-tools/logdata-sender.rb \
    --udp-data-count 50 --tcp-data-count 60 --syslog-data-count 70 --syslog-identifer "test-syslog" --duration 16 &

sleep 1

# Update to the next major version
sudo apt install -V -y \
    /host/v6-test/${distribution}/pool/${code_name}/${channel}/*/*/fluent-package_*_${architecture}.deb
test $main_pid -eq $(systemctl show --value --property=MainPID fluentd)

# Main process should be replaced by USR2 signal
sleep 20
test $main_pid -ne $(eval $(systemctl show fluentd --property=MainPID) && echo $MainPID)

# Stop fluentd to flush the logs and check
systemctl stop fluentd
test $(wc -l /var/log/fluent/test_udp*.log | tail -n 1 | awk '{print $1}') = "50"
test $(wc -l /var/log/fluent/test_tcp*.log | tail -n 1 | awk '{print $1}') = "60"
test $(grep "test-syslog" /var/log/fluent/test_syslog*.log | wc -l) = "70"
