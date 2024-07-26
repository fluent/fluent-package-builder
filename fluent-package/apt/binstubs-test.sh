#!/bin/bash

set -exu

echo "BINSTUBS TEST"
if [ "$CI" = "true" ]; then
   echo "::group::Setup binstubs test"
fi

apt update
apt install -V -y lsb-release

. $(dirname $0)/commonvar.sh

apt install -V -y \
  ${repositories_dir}/${distribution}/pool/${code_name}/${channel}/*/*/*_${architecture}.deb

if [ "$CI" = "true" ]; then
   echo "::endgroup::"
fi
/opt/fluent/bin/ruby /fluentd/fluent-package/binstubs-test.rb
if [ $? -eq 0 ]; then
    echo "Checking existence of binstubs: OK"
else
    echo "Checking existence of binstubs: NG"
    exit 1
fi
