#!/bin/bash

set -exu

. $(dirname $0)/commonvar.sh

package="/host/${distribution}/${DISTRIBUTION_VERSION}/x86_64/Packages/fluent-package-[0-9]*.rpm"

# Make a dummy pacakge for the next version
. $(dirname $0)/setup-rpmrebuild.sh

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

# Upgrade package with auto feature
sudo $DNF install -y $package
sudo systemctl enable --now fluentd
main_pid=$(eval $(systemctl show fluentd --property=MainPID) && echo $MainPID)

sudo $DNF install -y ./$next_package
test $main_pid -eq $(eval $(systemctl show fluentd --property=MainPID) && echo $MainPID)

# Main process should be replaced by USR2 signal in auto mode
sleep 15
test $main_pid -ne $(eval $(systemctl show fluentd --property=MainPID) && echo $MainPID)

sudo $DNF remove -y fluent-package

# Upgrade package with manual feature
sudo $DNF install -y $package
sudo systemctl enable --now fluentd
sudo sed -i 's/=auto/=manual/' /etc/sysconfig/fluentd
main_pid=$(eval $(systemctl show fluentd --property=MainPID) && echo $MainPID)

sudo $DNF install -y ./$next_package
test $main_pid -eq $(eval $(systemctl show fluentd --property=MainPID) && echo $MainPID)

# Main process should NOT be replaced until USR2 signal fired
sleep 15
test $main_pid -eq $(eval $(systemctl show fluentd --property=MainPID) && echo $MainPID)

sudo kill -USR2 $main_pid

# Main process should be replaced by USR2 signal
sleep 15
test $main_pid -ne $(eval $(systemctl show fluentd --property=MainPID) && echo $MainPID)
