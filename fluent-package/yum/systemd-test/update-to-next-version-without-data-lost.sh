#!/bin/bash

set -exu

. $(dirname $0)/commonvar.sh

sudo $DNF install -y rsyslog

# Install the current
package="/host/${distribution}/${DISTRIBUTION_VERSION}/x86_64/Packages/fluent-package-[0-9]*.rpm"
sudo $DNF install -y $package

# Make a dummy pacakge for the next version
case $distribution in
    amazon)
        case $version in
            2023)
                curl -L -o rpmrebuild.noarch.rpm https://sourceforge.net/projects/rpmrebuild/files/latest/download
                sudo $DNF install -y ./rpmrebuild.noarch.rpm
                ;;
            2)
                sudo amazon-linux-extras install -y epel
                sudo $DNF install -y rpmrebuild
                ;;
        esac
        ;;
    *)
        sudo $DNF install -y epel-release
        sudo $DNF install -y rpmrebuild
        ;;
esac

# Example: "1.el9"
release=$(rpmquery --queryformat="%{Release}" -p $package)
# Example: "1"
release_ver=$(echo $release | cut -d . -f1)
# Example: "2.el9"
next_release=$(($release_ver+1)).$(echo $release | cut -d. -f2)
rpmrebuild --release=$next_release --modify="find $HOME -name fluentd.service | xargs sed -i -E 's/FLUENT_PACKAGE_VERSION=([0-9.]+)/FLUENT_PACKAGE_VERSION=\1.1/g'" --package $package
next_package=$(find rpmbuild -name "*.rpm")
rpm2cpio $next_package | cpio -id ./usr/lib/systemd/system/fluentd.service
next_package_ver=$(cat ./usr/lib/systemd/system/fluentd.service | grep "FLUENT_PACKAGE_VERSION" | sed -E "s/Environment=FLUENT_PACKAGE_VERSION=(.+)/\1/")
echo "repacked next fluent-package version: $next_package_ver"

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

# Update to the next version
sudo $DNF install -y ./$next_package
test $main_pid -eq $(eval $(systemctl show fluentd --property=MainPID) && echo $MainPID)

sleep 3

# Stop fluentd to flush the logs and check
systemctl stop fluentd
test $(wc -l /var/log/fluent/test_udp*.log | cut -d' ' -f 1) = "50"
test $(wc -l /var/log/fluent/test_tcp*.log | cut -d' ' -f 1) = "60"
test $(grep "test-syslog" /var/log/fluent/test_syslog*.log | wc -l) = "70"
