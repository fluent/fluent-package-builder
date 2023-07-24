#!/bin/bash

set -exu

. $(dirname $0)/commonvar.sh

# Install v4
sudo rpm --import https://packages.treasuredata.com/GPG-KEY-td-agent
case ${distribution} in
    amazon)
        cat > td.repo <<'EOF';
[treasuredata]
name=TreasureData
baseurl=https://packages.treasuredata.com/4/amazon/$releasever/$basearch
gpgcheck=1
gpgkey=https://packages.treasuredata.com/GPG-KEY-td-agent
EOF
        sudo mv td.repo /etc/yum.repos.d/
        ;;
    *)
        cat > td.repo <<'EOF';
[treasuredata]
name=TreasureData
baseurl=https://packages.treasuredata.com/4/redhat/$releasever/$basearch
gpgcheck=1
gpgkey=https://packages.treasuredata.com/GPG-KEY-td-agent
EOF
        sudo mv td.repo /etc/yum.repos.d/
        ;;
esac
sudo $DNF update -y
sudo $DNF install -y td-agent-4.5.0-1.*.x86_64
sudo systemctl enable --now td-agent
systemctl status --no-pager td-agent

# Edit the logrotate config
test -e /etc/logrotate.d/td-agent
sudo sed -i"" /etc/logrotate.d/td-agent -e "s/rotate 30/rotate 40/g"

# Install the current
sudo $DNF install -y \
    /vagrant/${distribution}/${DISTRIBUTION_VERSION}/x86_64/Packages/fluent-package-[0-9]*.rpm
systemctl status --no-pager fluentd

# Test: logrotate config migration
#   RPM renames '/etc/logrotate.d/td-agent' to '/etc/logrotate.d/td-agent.rpmsave'.
#   Migration process restores '/etc/logrotate.d/td-agent' from the rpmsave and update the pid file path.
test -e /etc/logrotate.d/td-agent
test -e /var/log/fluent/td-agent.log

sudo $DNF install -y logrotate # rockylinux-8 needs to install logrotate
sleep 1
sudo logrotate -f /etc/logrotate.d/td-agent
sleep 1

test -e /var/log/fluent/td-agent.log.1
sudo cp /var/log/fluent/td-agent.log.1 saved_rotated_logfile
sudo systemctl stop fluentd
# Check that SIGUSR1 is sent to Fluentd and Fluentd reopens the logfile
# not to log to the rotated old file.
sudo diff --report-identical-files /var/log/fluent/td-agent.log.1 saved_rotated_logfile
