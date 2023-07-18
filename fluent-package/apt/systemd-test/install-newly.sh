#!/bin/bash

set -exu

. $(dirname $0)/../commonvar.sh

sudo apt install -V -y \
    /vagrant/${distribution}/pool/${code_name}/${channel}/*/*/fluent-package_*_${architecture}.deb

systemctl status --no-pager fluentd

sleep 3
! grep -q -e '\[warn\]' -e '\[error\]' -e '\[fatal\]' /var/log/fluent/fluentd.log

sudo apt remove -y fluent-package

test -h /etc/systemd/system/fluentd.service
! systemctl status fluentd
