#!/bin/bash

set -exu

apt update
apt install -V -y lsb-release

. $(dirname $0)/commonvar.sh

apt install -V -y \
  ${repositories_dir}/${distribution}/pool/${code_name}/${channel}/*/*/*_${architecture}.deb

td-agent --version

apt remove -y fluent-package


if ! getent passwd _fluentd >/dev/null; then
    echo "_fluentd user must be kept"
    exit 1
fi

if ! getent group _fluentd >/dev/null; then
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


if ! getent passwd td-agent >/dev/null; then
    echo "td-agent user must exist"
    exit 1
fi

if ! getent group td-agent >/dev/null; then
    echo "td-agent group must exist"
    exit 1
fi

if ! getent passwd _fluentd >/dev/null; then
    echo "_fluentd user must exist"
    exit 1
fi

if ! getent group _fluentd >/dev/null; then
    echo "_fluentd group must exist"
    exit 1
fi

if [ ! -h /var/log/td-agent ]; then
    echo "/var/log/td-agent must be symlink"
    exit 1
fi
if [ ! -h /etc/td-agent ]; then
    echo "/etc/td-agent must be symlink"
    exit 1
fi

owner=$(stat --format "%U/%G" /etc/fluent)
if [ "$owner" != "_fluentd/_fluentd" ]; then
    echo "/etc/fluent must be owned by _fluentd/_fluentd"
    exit 1
fi
owner=$(stat --format "%U/%G" /var/log/fluent)
if [ "$owner" != "_fluentd/_fluentd" ]; then
    echo "/var/log/fluent must be owned by _fluentd/_fluentd"
    exit 1
fi
owner=$(stat --format "%U/%G" /var/run/fluent)
if [ "$owner" != "_fluentd/_fluentd" ]; then
    echo "/var/run/fluent must be owned by _fluentd/_fluentd"
    exit 1
fi


