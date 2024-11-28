#!/bin/bash

set -exu

. $(dirname $0)/../commonvar.sh

# Install v4
sudo apt install -y curl ca-certificates
curl -fsSL https://toolbelt.treasuredata.com/sh/install-${distribution}-${code_name}-td-agent4.sh | sh

systemctl status --no-pager td-agent

# Generate garbage files
touch /etc/td-agent/a\ b\ c
touch /var/log/td-agent/a\ b\ c.log
touch /etc/td-agent/plugin/in_fake.rb
for d in $(seq 1 10); do
    touch /var/log/td-agent/$d.log
done

# Install the current
sudo apt install -V -y \
    /host/${distribution}/pool/${code_name}/${channel}/*/*/fluent-package_*_${architecture}.deb \
    /host/${distribution}/pool/${code_name}/${channel}/*/*/td-agent_*_all.deb
systemctl status --no-pager fluentd

sudo systemctl stop fluentd
sudo systemctl unmask td-agent
sudo systemctl enable --now fluentd

systemctl status --no-pager fluentd
systemctl status --no-pager td-agent

# Make a dummy pacakge for the next version
dpkg-deb -R /host/${distribution}/pool/${code_name}/${channel}/*/*/fluent-package_*_${architecture}.deb tmp
last_ver=$(cat tmp/DEBIAN/control | grep "Version: " | sed -E "s/Version: ([0-9.]+)-([0-9]+)/\2/g")
sed -i -E "s/Version: ([0-9.]+)-([0-9]+)/Version: \1-$(($last_ver+1))/g" tmp/DEBIAN/control
dpkg-deb --build tmp next_version.deb

# Install the dummy package
sudo apt install -V -y ./next_version.deb

# Test: service
systemctl status --no-pager fluentd
systemctl status --no-pager td-agent

# Test: keep compatibility with v4: symlinks for config files
test -h /etc/td-agent
test -h /etc/fluent/fluentd.conf
test $(readlink "/etc/fluent/fluentd.conf") = "/etc/fluent/td-agent.conf"
test -e /etc/td-agent/td-agent.conf
test -e /etc/fluent/plugin/in_fake.rb

# Test: keep compatibility with v4: symlinks for log files
test -h /var/log/td-agent
for d in $(seq 1 10); do
    test -e /var/log/fluent/$d.log
done

# Test: keep compatibility with v4: symlinks for bin files
test -h /usr/sbin/td-agent
test -h /usr/sbin/td-agent-gem

# Test: fluent-diagtool
sudo fluent-gem install fluent-plugin-concat
/opt/fluent/bin/fluent-diagtool -t fluentd -o /tmp
test $(find /tmp/ -name gem_local_list.output | xargs cat) = "fluent-plugin-concat"

# Test: No error logs
# (v4 default config outputs 'warn' log, so we should check only 'error' and 'fatal' logs)
sleep 3
test -e /var/log/fluent/fluentd.log
(! grep -e '\[error\]' -e '\[fatal\]' /var/log/fluent/fluentd.log)

# Test: Guard duplicated instance
(! sudo /usr/sbin/fluentd)
(! sudo /usr/sbin/td-agent)
(! sudo /usr/sbin/fluentd -v)
sudo /usr/sbin/fluentd --dry-run

# Uninstall
sudo apt remove -y fluent-package
(! systemctl status --no-pager td-agent)
(! systemctl status --no-pager fluentd)
