#!/bin/bash

set -exu

. $(dirname $0)/../commonvar.sh

case $1 in
  local)
    sudo apt install -V -y \
      /host/${distribution}/pool/${code_name}/${channel}/*/*/fluent-package_*_${architecture}.deb
    (! systemctl status fluentd)
    sudo systemctl enable --now fluentd
    ;;
  v5)
    curl --fail --silent --show-error --location https://toolbelt.treasuredata.com/sh/install-${distribution}-${code_name}-fluent-package5.sh | sh
    ;;
  lts)
    curl --fail --silent --show-error --location https://toolbelt.treasuredata.com/sh/install-${distribution}-${code_name}-fluent-package5-lts.sh | sh
    ;;
esac

systemctl status --no-pager fluentd

sleep 3
test -e /var/log/fluent/fluentd.log
(! grep -q -e '\[warn\]' -e '\[error\]' -e '\[fatal\]' /var/log/fluent/fluentd.log)

# Test: fluent-diagtool
sudo fluent-gem install fluent-plugin-concat
/opt/fluent/bin/fluent-diagtool -t fluentd -o /tmp
test $(find /tmp/ -name gem_local_list.output | xargs cat) = "fluent-plugin-concat"

# Test: Guard duplicated instance
if [ "$1" = "local" ]; then
    # FIXME: until guard feature was released, skip v5 and lts.
    (! sudo /usr/sbin/fluentd)
    (! sudo /usr/sbin/fluentd -v)
    sudo /usr/sbin/fluentd --dry-run
fi

sudo apt remove -y fluent-package

case ${code_name} in
  bookworm|noble)
    # no dead fluentd.service symlink in /etc/systemd/system
    (! test -h /etc/systemd/system/fluentd.service)
    test -h /etc/systemd/system/multi-user.target.wants/fluentd.service
    (! test -s /etc/systemd/system/multi-user.target.wants/fluentd.service)
    ;;
  *)
    # dead fluentd.service symlink in /etc/systemd/system
    test -h /etc/systemd/system/fluentd.service
    (! test -s /etc/systemd/system/fluentd.service)
    test -h /etc/systemd/system/multi-user.target.wants/fluentd.service
    (! test -s /etc/systemd/system/multi-user.target.wants/fluentd.service)
    ;;
esac
test -h /etc/systemd/system/td-agent.service
(! test -s /etc/systemd/system/td-agent.service)
(! systemctl status fluentd)

