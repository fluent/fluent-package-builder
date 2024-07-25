#!/bin/bash

set -exu

export DEBIAN_FRONTEND=noninteractive

if [ "$CI" = "true" ]; then
   echo "::group::Setup serverspec test"
fi

apt update
apt install -V -y lsb-release

. $(dirname $0)/commonvar.sh

apt install -V -y \
  ${repositories_dir}/${distribution}/pool/${code_name}/${channel}/*/*/*_${architecture}.deb

fluentd --version

if [ "$CI" = "true" ]; then
   echo "::endgroup::"
fi

export PATH=/opt/fluent/bin:$PATH
export INSTALLATION_TEST=true
/usr/sbin/fluent-gem install --no-document serverspec
cd /fluentd && rake serverspec:linux
