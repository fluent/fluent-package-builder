#!/bin/bash

set -exu

. $(dirname $0)/../commonvar.sh

case $1 in
  local)
    sudo apt install -V -y \
      /vagrant/${distribution}/pool/${code_name}/${channel}/*/*/fluent-package_*_${architecture}.deb
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

sudo apt remove -y fluent-package

test -h /etc/systemd/system/fluentd.service
(! systemctl status fluentd)
