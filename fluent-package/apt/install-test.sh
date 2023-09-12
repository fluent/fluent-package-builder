#!/bin/bash

set -exu

apt update
apt install -V -y lsb-release

. $(dirname $0)/commonvar.sh

apt install -V -y \
  ${repositories_dir}/${distribution}/pool/${code_name}/${channel}/*/*/*_${architecture}.deb

fluentd --version
test -e /etc/logrotate.d/fluentd
test -e /opt/fluent/share/fluentd.conf
(! test -h /usr/sbin/td-agent)
(! test -h /usr/sbin/td-agent-gem)

apt remove -y fluent-package

test -e /etc/logrotate.d/fluentd
(! test -e /opt/fluent/share/fluentd.conf)
(! test -h /usr/sbin/td-agent)
(! test -h /usr/sbin/td-agent-gem)

getent passwd _fluentd >/dev/null
getent group _fluentd >/dev/null

echo "fluent-apt-source test"
apt_source_repositories_dir=/fluentd/fluent-apt-source/apt/repositories
apt purge -y fluent-package

for conf_path in /etc/td-agent/td-agent.conf /etc/fluent/fluentd.conf; do
    if [ -e $conf_path ]; then
        echo "$conf_path must be removed"
        exit 1
    fi
done

if [ "${code_name}" == "bookworm" ]; then
    echo "As bookworm is not published for v4, so package upgrade install check for ${code_name} is disabled"
    exit 0
fi
# TODO: Remove it when v5 repository was deployed
apt install -y curl
curl -O https://packages.treasuredata.com/4/${distribution}/${code_name}/pool/contrib/f/fluentd-apt-source/fluentd-apt-source_2020.8.25-1_all.deb
apt install -y ./fluentd-apt-source_2020.8.25-1_all.deb

apt clean all
# Uncomment when v5 repository was deployed
#apt_source_package=${apt_source_repositories_dir}/${distribution}/pool/${code_name}/${channel}/*/*/fluent-apt-source*_all.deb
#apt install -V -y ${apt_source_package} ca-certificates
apt update
apt install -V -y td-agent

apt install -V -y \
  ${repositories_dir}/${distribution}/pool/${code_name}/${channel}/*/*/*_${architecture}.deb

getent passwd td-agent >/dev/null
getent group td-agent >/dev/null
getent passwd _fluentd >/dev/null
getent group _fluentd >/dev/null

test -h /var/log/td-agent
test -h /etc/td-agent
test -h /usr/sbin/td-agent
test -h /usr/sbin/td-agent-gem

homedir=$(getent passwd _fluentd | cut -d: -f6)
test "$homedir" = "/var/lib/fluent"

loginshell=$(getent passwd _fluentd | cut -d: -f7)
test "$loginshell" = "/usr/sbin/nologin"

# Note: As td-agent and _fluentd use same UID/GID,
# it is regarded as preceding name (td-agent)
owner=$(stat --format "%U/%G" /etc/fluent)
test "$owner" = "td-agent/td-agent"
owner=$(stat --format "%U/%G" /var/log/fluent)
test "$owner" = "td-agent/td-agent"
owner=$(stat --format "%U/%G" /var/run/fluent)
test "$owner" = "td-agent/td-agent"
