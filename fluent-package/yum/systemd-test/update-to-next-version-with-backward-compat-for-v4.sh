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
sudo $DNF install -y td-agent-${td_agent_version}-1.*.x86_64

sudo systemctl enable --now td-agent
systemctl status --no-pager td-agent

# Install the current
package="/vagrant/${distribution}/${DISTRIBUTION_VERSION}/x86_64/Packages/fluent-package-[0-9]*.rpm"
sudo $DNF install -y $package
systemctl status --no-pager fluentd # Migration process starts the service automatically
sudo systemctl enable --now fluentd
systemctl status --no-pager td-agent

# Make a dummy pacakge for the next version
case $distribution in
    amazon)
        sudo amazon-linux-extras install -y epel
        ;;
    *)
        sudo $DNF install -y epel-release
        ;;
esac
sudo $DNF install -y rpmrebuild
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
sudo systemctl enable --now fluentd

# Test: service
systemctl status --no-pager fluentd
systemctl status --no-pager td-agent

# Test: keep compatibility with v4: symlinks for config files
test -h /etc/td-agent
test -h /etc/fluent/fluentd.conf
test $(readlink "/etc/fluent/fluentd.conf") = "/etc/fluent/td-agent.conf"
test -e /etc/td-agent/td-agent.conf

# Test: config migration
test -h /etc/td-agent
test -h /etc/fluent/fluentd.conf
test $(readlink "/etc/fluent/fluentd.conf") = "/etc/fluent/td-agent.conf"
test -e /etc/td-agent/td-agent.conf

# Test: keep compatibility with v4: symlinks for log files
test -h /var/log/td-agent

# Test: keep compatibility with v4: symlinks for bin files
test -h /usr/sbin/td-agent
test -h /usr/sbin/td-agent-gem

# Test: No error logs
# (v4 default config outputs 'warn' log, so we should check only 'error' and 'fatal' logs)
sleep 3
test -e /var/log/fluent/fluentd.log
(! grep -e '\[error\]' -e '\[fatal\]' /var/log/fluent/fluentd.log)

# Uninstall
sudo $DNF remove -y fluent-package
(! systemctl status --no-pager td-agent)
(! systemctl status --no-pager fluentd)
