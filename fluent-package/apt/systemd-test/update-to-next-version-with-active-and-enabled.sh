#!/bin/bash

set -exu

. $(dirname $0)/../commonvar.sh

# Remove needrestart package to avoid auto restart outside our contorol
sudo apt autoremove -y needrestart --purge

# Install the current
sudo apt install -V -y \
    /host/${distribution}/pool/${code_name}/${channel}/*/*/fluent-package_*_${architecture}.deb

# Make a dummy pacakge for the next version
dpkg-deb -R /host/${distribution}/pool/${code_name}/${channel}/*/*/fluent-package_*_${architecture}.deb tmp
last_ver=$(cat tmp/DEBIAN/control | grep "Version: " | sed -E "s/Version: ([0-9.]+)-([0-9]+)/\2/g")
sed -i -E "s/Version: ([0-9.]+)-([0-9]+)/Version: \1-$(($last_ver+1))/g" tmp/DEBIAN/control
dpkg-deb --build tmp next_version.deb

# The service should NOT start automatically
(! systemctl is-active fluentd)
# The service should be enabled by default
systemctl is-enabled fluentd

# Enable and start the service
sudo systemctl enable --now fluentd
systemctl is-active fluentd
systemctl is-enabled fluentd

main_pid=$(systemctl show --value --property=MainPID fluentd)

# Install the dummy package
sudo apt install -V -y ./next_version.deb

systemctl is-active fluentd
systemctl is-enabled fluentd

# The service should NOT restart automatically after update
test $main_pid -eq $(systemctl show --value --property=MainPID fluentd)
