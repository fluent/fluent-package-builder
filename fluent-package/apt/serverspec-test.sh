#!/bin/bash

set -exu

export DEBIAN_FRONTEND=noninteractive

if [ "$CI" = "true" ]; then
   echo "::group::Setup serverspec test"
fi

apt update --quiet
apt install -V -y --quiet lsb-release

. $(dirname $0)/commonvar.sh

apt install -V -y --quiet \
  ${repositories_dir}/${distribution}/pool/${code_name}/${channel}/*/*/*_${architecture}.deb

fluentd --version

if [ "$CI" = "true" ]; then
   echo "::endgroup::"
fi

export PATH=/opt/fluent/bin:$PATH
export INSTALLATION_TEST=true
/usr/sbin/fluent-gem install --no-document serverspec
cd /fluentd && rake serverspec:linux
