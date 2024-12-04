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
case $1 in
  local)
    sudo apt install -V -y \
      /host/${distribution}/pool/${code_name}/${channel}/*/*/fluent-package_*_${architecture}.deb \
      /host/${distribution}/pool/${code_name}/${channel}/*/*/td-agent_*_all.deb 2>&1 | tee upgrade.log
    # Test: needrestart was suppressed
    if dpkg-query --show --showformat='${Version}' needrestart ; then
      case $code_name in
        focal)
          # dpkg-query succeeds even though needrestart is not installed.
          (! grep "No services need to be restarted." upgrade.log)
          ;;
        *)
          grep "No services need to be restarted." upgrade.log
          ;;
      esac
    fi
    ;;
  v5)
    curl --fail --silent --show-error --location https://toolbelt.treasuredata.com/sh/install-${distribution}-${code_name}-fluent-package5.sh | sh
    ;;
  lts)
    curl --fail --silent --show-error --location https://toolbelt.treasuredata.com/sh/install-${distribution}-${code_name}-fluent-package5-lts.sh | sh
    ;;
esac

# Test: service status
systemctl status --no-pager fluentd
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
