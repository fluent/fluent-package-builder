#!/bin/bash

set -exu

. $(dirname $0)/../commonvar.sh

sudo apt install -V -y \
    /vagrant/${distribution}/pool/${code_name}/${channel}/*/*/fluent-package_*_${architecture}.deb

systemctl status --no-pager fluentd

sudo apt remove -y fluent-package

! systemctl status fluentd
