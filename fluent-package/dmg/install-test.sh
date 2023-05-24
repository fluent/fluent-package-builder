#!/bin/bash

dmg_path=$1

set -exu

test -e $dmg_path

hdiutil mount $dmg_path
sudo installer -pkg /Volumes/fluent-package/*.pkg -target / -allowUntrusted
sudo launchctl load /Library/LaunchDaemons/fluentd.plist
hdiutil detach /Volumes/fluent-package

sleep 10 # Wait for Fluentd to start up and run correctly.
test $(sudo launchctl list fluentd | grep LastExitStatus | grep -oE "[0-9]+") = 0

sudo launchctl unload /Library/LaunchDaemons/fluentd.plist
sudo rm -rf /opt/fluent/ /etc/td-agent/ /var/log/td-agent /Library/LaunchDaemons/fluentd.plist
