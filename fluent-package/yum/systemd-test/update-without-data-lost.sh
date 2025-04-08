#!/bin/bash

set -exu

. $(dirname $0)/commonvar.sh

v5_package="/host/${distribution}/${DISTRIBUTION_VERSION}/x86_64/Packages/fluent-package-*.rpm"
v6_package="/host/v6-test/${distribution}/${DISTRIBUTION_VERSION}/x86_64/Packages/fluent-package-*.rpm"

case "$1" in
    v5)
        package=$v5_package
        ;;
    v6)
        package=$v6_package
        ;;
    *)
        echo "Invalid argument: $1"
        exit 1
        ;;
esac

command="install"
case "$2" in
    v5)
        next_package=$v5_package
        command="downgrade" # Avoid error in AmazonLinux2
        ;;
    v6)
        next_package=$v6_package
        ;;
    *)
        echo "Invalid argument: $2"
        exit 1
        ;;
esac

sudo $DNF install -y rsyslog

# Install the current
sudo $DNF install -y $package

# Set up configuration
cat < $(dirname $0)/../../test-tools/rsyslog.conf | sudo tee -a /etc/rsyslog.conf
sudo cp $(dirname $0)/../../test-tools/fluentd.conf /etc/fluent/fluentd.conf

# Launch rsyslog
sudo systemctl restart rsyslog

# Launch fluentd
sudo systemctl enable --now fluentd
main_pid=$(eval $(systemctl show fluentd --property=MainPID) && echo $MainPID)

# Ensure to wait for fluentd launching
sleep 1

# Send logs in background for 4 seconds
/opt/fluent/bin/ruby $(dirname $0)/../../test-tools/logdata-sender.rb \
    --udp-data-count 50 --tcp-data-count 60 --syslog-data-count 70 --syslog-identifer "test-syslog" --duration 16 &

sleep 1

# Update to the next version
sudo $DNF $command -y $next_package
test $main_pid -eq $(eval $(systemctl show fluentd --property=MainPID) && echo $MainPID)

# Main process should be replaced by USR2 signal
sleep 20
test $main_pid -ne $(eval $(systemctl show fluentd --property=MainPID) && echo $MainPID)

# Stop fluentd to flush the logs and check
sudo systemctl stop fluentd
test $(wc -l /var/log/fluent/test_udp*.log | tail -n 1 | awk '{print $1}') = "50"
test $(wc -l /var/log/fluent/test_tcp*.log | tail -n 1 | awk '{print $1}') = "60"
test $(grep "test-syslog" /var/log/fluent/test_syslog*.log | wc -l) = "70"
