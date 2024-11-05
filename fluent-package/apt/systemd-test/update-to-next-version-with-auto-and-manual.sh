#!/bin/bash

set -exu

. $(dirname $0)/../commonvar.sh

package="/host/${distribution}/pool/${code_name}/${channel}/*/*/fluent-package_*_${architecture}.deb"

# Make a dummy pacakge for the next version
dpkg-deb -R /host/${distribution}/pool/${code_name}/${channel}/*/*/fluent-package_*_${architecture}.deb tmp
last_ver=$(cat tmp/DEBIAN/control | grep "Version: " | sed -E "s/Version: ([0-9.]+)-([0-9]+)/\2/g")
sed -i -E "s/Version: ([0-9.]+)-([0-9]+)/Version: \1-$(($last_ver+1))/g" tmp/DEBIAN/control
dpkg-deb --build tmp next_version.deb

# Upgrade package with auto feature
sudo apt install -V -y $package
main_pid=$(eval $(systemctl show fluentd --property=MainPID) && echo $MainPID)

sudo apt install -V -y ./next_version.deb
test $main_pid -eq $(eval $(systemctl show fluentd --property=MainPID) && echo $MainPID)

# Main process should be replaced by USR2 signal in auto mode
sleep 15
test $main_pid -ne $(eval $(systemctl show fluentd --property=MainPID) && echo $MainPID)

sudo apt purge -y fluent-package

# Upgrade package with manual feature
sudo apt install -V -y $package
sed -i 's/=auto/=manual/' /etc/default/fluentd
# TODO: Clarify the specification of FLUENT_PACKAGE_SERVICE_RESTART environment variable
sudo systemctl restart fluentd
main_pid=$(eval $(systemctl show fluentd --property=MainPID) && echo $MainPID)

sudo apt install -V -y ./next_version.deb
test $main_pid -eq $(eval $(systemctl show fluentd --property=MainPID) && echo $MainPID)

# Main process should NOT be replaced until USR2 signal fired
sleep 15
test $main_pid -eq $(eval $(systemctl show fluentd --property=MainPID) && echo $MainPID)

kill -USR2 $main_pid

# Main process should be replaced by USR2 signal
sleep 15
test $main_pid -ne $(eval $(systemctl show fluentd --property=MainPID) && echo $MainPID)
