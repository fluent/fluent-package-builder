#!/bin/bash

set -xu

apt update
apt install -V -y lsb-release

. $(dirname $0)/commonvar.sh

apt install -V -y \
  ${repositories_dir}/${distribution}/pool/${code_name}/${channel}/*/*/*_${architecture}.deb

td-agent --version

apt remove -y fluent-package

getent passwd _fluentd >/dev/null
if [ $? -ne 0 ]; then
    echo "_fluentd user must be kept"
    exit 1
fi
getent group _fluentd >/dev/null
if [ $? -ne 0 ]; then
    echo "_fluentd group must be kept"
    exit 1
fi

echo "fluentd-apt-source test"
apt_source_repositories_dir=/fluentd/fluentd-apt-source/apt/repositories
apt purge -y fluent-package

for conf_path in /etc/td-agent/td-agent.conf /etc/fluent/fluentd.conf; do
    if [ -e $conf_path ]; then
	echo "$conf_path must be removed"
	exit 1
    fi
done

if [ ${code_name} = "jammy" ]; then
    # TODO: Remove when repository for jammy has been deployed
    echo "skip to install via apt repository: <${code_name}>"
    exit 0
fi
apt clean all
apt_source_package=${apt_source_repositories_dir}/${distribution}/pool/${code_name}/${channel}/*/*/fluentd-apt-source*_all.deb
apt install -V -y ${apt_source_package} ca-certificates
apt update
apt install -V -y td-agent

apt install -V -y \
  ${repositories_dir}/${distribution}/pool/${code_name}/${channel}/*/*/*_${architecture}.deb

getent passwd td-agent >/dev/null
if [ $? -eq 0 ]; then
    echo "td-agent user must be removed"
    exit 1
fi
getent group td-agent >/dev/null
if [ $? -eq 0 ]; then
    echo "td-agent group must be removed"
    exit 1
fi
getent passwd _fluentd >/dev/null
if [ $? -ne 0 ]; then
    echo "_fluentd user must exist"
    exit 1
fi
getent group _fluentd >/dev/null
if [ $? -ne 0 ]; then
    echo "_fluentd group must exist"
    exit 1
fi

if [ ! -s /var/log/td-agent ]; then
    echo "/var/log/td-agent must be symlink"
    exit 1
fi
if [ ! -s /etc/td-agent ]; then
    echo "/etc/td-agent must be symlink"
    exit 1
fi

