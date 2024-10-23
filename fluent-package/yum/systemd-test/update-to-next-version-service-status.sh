#!/bin/bash

set -exu

. $(dirname $0)/commonvar.sh

enabled_before_update=$1 # enabled / disabled
status_before_update=$2 # active / inactive

# Install the current
package="/host/${distribution}/${DISTRIBUTION_VERSION}/x86_64/Packages/fluent-package-[0-9]*.rpm"
sudo $DNF install -y $package

# The service should NOT start automatically
(! systemctl is-active fluentd)
# The service should be DISabled by default
(! systemctl is-enabled fluentd)

# Start the service
if [ "$enabled_before_update" = enabled ]; then
    sudo systemctl enable fluentd
fi
if [ "$status_before_update" = active ]; then
    sudo systemctl start fluentd
fi

main_pid=$(eval $(systemctl show fluentd --property=MainPID) && echo $MainPID)

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
rpmrebuild --release=$next_release --package $package
next_package=$(find rpmbuild -name "*.rpm")

# Install the dummy package of the next version
sudo $DNF install -y ./$next_package

# The service should take over the state
if [ "$enabled_before_update" = enabled ]; then
    systemctl is-enabled fluentd
else
    (! systemctl is-enabled fluentd)
fi

if [ "$status_before_update" = active ]; then
    # The service should NOT restart automatically after update
    systemctl is-active fluentd
    test $main_pid -eq $(eval $(systemctl show fluentd --property=MainPID) && echo $MainPID)
else
    # The service should NOT start automatically
    (! systemctl is-active fluentd)
fi
