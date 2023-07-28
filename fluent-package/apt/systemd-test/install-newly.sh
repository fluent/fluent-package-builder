#!/bin/bash

set -exu

. $(dirname $0)/../commonvar.sh

case $1 in
  local)
    sudo apt install -V -y \
      /vagrant/${distribution}/pool/${code_name}/${channel}/*/*/fluent-package_*_${architecture}.deb
    ;;
  v5)
    curl -o fluent-apt-source.deb \
      https://packages.treasuredata.com/5/${distribution}/${code_name}/pool/contrib/f/fluent-apt-source/fluent-apt-source_2023.6.29-1_all.deb
    sudo apt install -V -y ./fluent-apt-source.deb
    sudo apt update
    sudo apt install -y fluent-package
    ;;
  lts)
    curl -o fluent-lts-apt-source.deb \
      https://packages.treasuredata.com/lts/5/${distribution}/${code_name}/pool/contrib/f/fluent-lts-apt-source/fluent-lts-apt-source_2023.7.29-1_all.deb
    sudo apt install -V -y ./fluent-lts-apt-source.deb
    sudo apt update
    sudo apt install -y fluent-package
    ;;
esac

systemctl status --no-pager fluentd

sleep 3
test -e /var/log/fluent/fluentd.log
(! grep -q -e '\[warn\]' -e '\[error\]' -e '\[fatal\]' /var/log/fluent/fluentd.log)

sudo apt remove -y fluent-package

test -h /etc/systemd/system/fluentd.service
(! systemctl status fluentd)
