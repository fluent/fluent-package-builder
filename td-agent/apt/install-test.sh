#!/bin/bash

set -exu

apt update
apt install -V -y lsb-release

. $(dirname $0)/commonvar.sh

apt install -V -y \
  ${repositories_dir}/${distribution}/pool/${code_name}/${channel}/*/*/*_${architecture}.deb

td-agent --version

apt remove -y td-agent

conf_path=/etc/td-agent/td-agent.conf
if [ ! -f $conf_path ]; then
    echo "td-agent.conf must be exist: <${conf_path}>"
    exit 1
fi
if [ ! -s $conf_path ]; then
    echo "td-agent.conf size must not be zero: <${conf_path}>"
    exit 1
fi

echo "fluentd-apt-source test"
apt_source_repositories_dir=/fluentd/fluentd-apt-source/apt/repositories
apt purge -y td-agent

conf_path=/etc/td-agent/td-agent.conf
if [ -e $conf_path ]; then
    echo "td-agent.conf must be purged: <${conf_path}>"
    exit 1
fi

if [ ${code_name} = "jammy" ]; then
    # TODO: Remove when repository for jammy has been deployed
    echo "skip to install via apt repository: <${code_name}>"
    exit 0
fi
apt clean all
apt_source_package=${apt_source_repositories_dir}/${distribution}/pool/${code_name}/${channel}/*/*/fluentd-apt-source*_all.deb
apt install -V -y ${apt_source_package}
apt update
apt install -V -y td-agent
