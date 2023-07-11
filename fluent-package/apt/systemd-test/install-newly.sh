#!/bin/bash

set -exu

. $(dirname $0)/../commonvar.sh

sudo apt install -V -y \
    /vagrant/${distribution}/pool/${code_name}/${channel}/*/*/fluent-package_*_${architecture}.deb

systemctl status --no-pager fluentd

sudo apt remove -y fluent-package

if [ ! -e /etc/systemd/system/td-agent.service ]; then
    echo "td-agent.service must exist"
    exit 1
fi
if [ ! -e /etc/systemd/system/fluentd.service ]; then
    echo "fluentd.service must exist"
    exit 1
fi

! systemctl status fluentd
