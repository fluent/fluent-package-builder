#!/bin/bash

set -exu

sudo apt update
sudo apt install -V -y lsb-release

. $(dirname $0)/commonvar.sh

sudo apt install -V -y \
  /vagrant/${distribution}/pool/${code_name}/${channel}/*/*/*_${architecture}.deb

systemctl status fluentd

sudo apt remove -y fluent-package

! systemctl status fluentd
