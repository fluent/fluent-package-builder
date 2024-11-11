#!/bin/bash

set -exu

. $(dirname $0)/../commonvar.sh

# TODO: Remove it when v5 repository was deployed
sudo apt install -y curl ca-certificates
curl -O https://packages.treasuredata.com/4/${distribution}/${code_name}/pool/contrib/f/fluentd-apt-source/fluentd-apt-source_2020.8.25-1_all.deb
sudo apt install -y ./fluentd-apt-source_2020.8.25-1_all.deb

# Install v4
sudo apt clean all
# Uncomment when v5 repository was deployed
#apt_source_package=/host/${distribution}/pool/${code_name}/${channel}/*/*/fluent-apt-source*_all.deb
#sudo apt install -V -y ${apt_source_package} ca-certificates
sudo apt update
sudo apt install -V -y td-agent=${td_agent_version}-1

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

# Test: service status
systemctl status --no-pager fluentd
# BUG: v4 service restart logic will not launched usually because the
# existence check of td-agent.service will always fail.
# As a result, old service is still alive here.
systemctl status --no-pager td-agent

# Test: restoring td-agent service alias
sudo systemctl stop fluentd
sudo systemctl unmask td-agent
sudo systemctl enable --now fluentd

systemctl status --no-pager td-agent
systemctl status --no-pager fluentd

# Test: config migration
test -h /etc/td-agent
test -h /etc/fluent/fluentd.conf
test $(readlink "/etc/fluent/fluentd.conf") = "/etc/fluent/td-agent.conf"
test -e /etc/td-agent/td-agent.conf
test -e /etc/fluent/a\ b\ c
test -e /etc/fluent/plugin/in_fake.rb

# Test: log file migration
test -h /var/log/td-agent
test -e /var/log/td-agent/td-agent.log
for d in $(seq 1 10); do
    test -e /var/log/fluent/$d.log
done

# Test: bin file migration
test -h /usr/sbin/td-agent
test -h /usr/sbin/td-agent-gem

# Test: environmental variables
pid=$(systemctl show fluentd --property=MainPID --value)
env_vars=$(sudo sed -e 's/\x0/\n/g' /proc/$pid/environ)
test $(eval $env_vars && echo $HOME) = "/var/lib/fluent"
test $(eval $env_vars && echo $LOGNAME) = "_fluentd"
test $(eval $env_vars && echo $USER) = "_fluentd"
test $(eval $env_vars && echo $FLUENT_CONF) = "/etc/fluent/fluentd.conf"
test $(eval $env_vars && echo $FLUENT_PACKAGE_LOG_FILE) = "/var/log/fluent/fluentd.log"
test $(eval $env_vars && echo $FLUENT_PLUGIN) = "/etc/fluent/plugin"
test $(eval $env_vars && echo $FLUENT_SOCKET) = "/var/run/fluent/fluentd.sock"

# Test: No error logs
# (v4 default config outputs 'warn' log, so we should check only 'error' and 'fatal' logs)
sleep 3
test -e /var/log/fluent/fluentd.log
(! grep -e '\[error\]' -e '\[fatal\]' /var/log/fluent/fluentd.log)

# Test: fluent-diagtool
sudo fluent-gem install fluent-plugin-concat
/opt/fluent/bin/fluent-diagtool -t fluentd -o /tmp
test $(find /tmp/ -name gem_local_list.output | xargs cat) = "fluent-plugin-concat"

# Test: Guard duplicated instance
(! sudo /usr/sbin/fluentd)
(! sudo /usr/sbin/td-agent)
(! sudo /usr/sbin/fluentd -v)
sudo /usr/sbin/fluentd --dry-run

# Uninstall
sudo apt remove -y fluent-package
(! systemctl status --no-pager td-agent)
(! systemctl status --no-pager fluentd)

test -h /etc/systemd/system/td-agent.service
(! test -s /etc/systemd/system/td-agent.service)
test -h /etc/systemd/system/fluentd.service
(! test -s /etc/systemd/system/fluentd.service)
test -h /etc/systemd/system/multi-user.target.wants/fluentd.service
(! test -s /etc/systemd/system/multi-user.target.wants/fluentd.service)
