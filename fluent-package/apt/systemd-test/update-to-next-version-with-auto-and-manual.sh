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
sudo systemctl enable --now fluentd
sed -i 's/=auto/=manual/' /etc/default/fluentd
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

sudo apt purge -y fluent-package

# Upgrade package without /etc/default/fluentd
# It is optional, and dpkg does not restore the removed conffile on upgrade.
# Without it, auto feature should be used.
sudo apt install -V -y $package
sudo systemctl enable --now fluentd
sudo rm /etc/default/fluentd
main_pid=$(eval $(systemctl show fluentd --property=MainPID) && echo $MainPID)

(set -o pipefail; sudo apt install -V -y ./next_version.deb 2>&1 | tee upgrade.log)
(! grep "pre-removal script subprocess returned error" upgrade.log)
(! test -e /etc/default/fluentd)
test $main_pid -eq $(eval $(systemctl show fluentd --property=MainPID) && echo $MainPID)

# Main process should be replaced by USR2 signal in auto mode
sleep 15
test $main_pid -ne $(eval $(systemctl show fluentd --property=MainPID) && echo $MainPID)

sudo apt purge -y fluent-package

# Complete the upgrade after the service is restarted
# It happens when the upgrade is interrupted (e.g. by a reboot) after unpacking,
# and completed later by dpkg --configure -a.
# The PID recorded by prerm is stale, so auto restart should not kick it.
sudo apt install -V -y $package
sudo systemctl enable --now fluentd
sudo dpkg --unpack ./next_version.deb
sudo systemctl restart fluentd
main_pid=$(eval $(systemctl show fluentd --property=MainPID) && echo $MainPID)

(set -o pipefail; sudo dpkg --configure fluent-package 2>&1 | tee configure.log)
grep "Do not use auto restart" configure.log
(! grep "Kick auto restart" configure.log)
(! test -e /var/cache/fluent/.pid_for_auto_restart)

# Main process should NOT be replaced
sleep 15
test $main_pid -eq $(eval $(systemctl show fluentd --property=MainPID) && echo $MainPID)
