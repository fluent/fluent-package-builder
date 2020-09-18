#!/bin/bash

set -exu

apt update
apt install -V -y lsb-release

. $(dirname $0)/commonvar.sh

apt install -V -y \
  ${repositories_dir}/${distribution}/pool/${code_name}/${channel}/*/*/*_${architecture}.deb

td-agent --version

echo "td-agent-apt-source test"
apt_source_repositories_dir=/fluentd/td-agent-apt-source/apt/repositories
apt purge -y td-agent
apt clean all
apt_source_package=${apt_source_repositories_dir}/${distribution}/pool/${code_name}/${channel}/*/*/td-agent-apt-source*_all.deb
apt install -V -y ${apt_source_package}
apt update
apt install -V -y td-agent
