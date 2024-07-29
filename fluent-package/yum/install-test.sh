#!/bin/bash

set -exu

# Amazon Linux 2 system-release-cpe is:
# cpe:2.3:o:amazon:amazon_linux:2
# CentOS 7 system-release-cpe is:
# cpe:/o:centos:centos:7
# CentOS 6 system-release-cpe is:
# cpe:/o:centos:linux:6
# This means that column glitch exists.
# So, we should remove before "o" character.

distribution=$(cat /etc/system-release-cpe | awk '{print substr($0, index($0, "o"))}' | cut -d: -f2)
version=$(cat /etc/system-release-cpe | awk '{print substr($0, index($0, "o"))}' | cut -d: -f4)

ENABLE_UPGRADE_TEST=1
case ${distribution} in
  amazon)
    case ${version} in
      2)
        DNF=yum
        DISTRIBUTION_VERSION=${version}
        ;;
      2023)
        ENABLE_UPGRADE_TEST=0
        DNF=dnf
        DISTRIBUTION_VERSION=${version}
        ;;
    esac
    ;;
  centos)
    case ${version} in
      7)
        DNF=yum
        DISTRIBUTION_VERSION=${version}
        ;;
      *)
        DNF="dnf --enablerepo=powertools"
        ENABLE_UPGRADE_TEST=0
        if [ x"${CENTOS_STREAM}" == x"true" ]; then
            echo "MIGRATE TO CENTOS STREAM"
            ${DNF} install centos-release-stream -y && \
                ${DNF} swap centos-{linux,stream}-repos -y && \
                ${DNF} distro-sync -y
            DISTRIBUTION_VERSION=${version}-stream
        else
            DISTRIBUTION_VERSION=${version}
        fi
        ;;
    esac
    ;;
  rocky|almalinux)
    ENABLE_UPGRADE_TEST=0
    DNF=dnf
    DISTRIBUTION_VERSION=$(echo ${version} | cut -d. -f1)
    ;;
esac

echo "INSTALL TEST"
repositories_dir=/fluentd/fluent-package/yum/repositories
${DNF} install -y \
  ${repositories_dir}/${distribution}/${DISTRIBUTION_VERSION}/x86_64/Packages/*.rpm

fluentd --version
test -e /etc/logrotate.d/fluentd
test -e /opt/fluent/share/fluentd.conf
(! test -h /usr/sbin/td-agent)
(! test -h /usr/sbin/td-agent-gem)

echo "UNINSTALL TEST"
${DNF} remove -y fluent-package

(! test -e /etc/logrotate.d/fluentd)
(! test -e /opt/fluent/share/fluentd.conf)
(! test -h /usr/sbin/td-agent)
(! test -h /usr/sbin/td-agent-gem)

for conf_path in /etc/td-agent/td-agent.conf /etc/fluent/fluentd.conf; do
    if [ -e $conf_path ]; then
        echo "$conf_path must be removed"
        exit 1
    fi
done

getent passwd fluentd >/dev/null
getent group fluentd >/dev/null

if [ $ENABLE_UPGRADE_TEST -eq 1 ]; then
    echo "UPGRADE TEST from v4"
    rpm --import https://packages.treasuredata.com/GPG-KEY-td-agent
    case ${distribution} in
        amazon)
            cat >/etc/yum.repos.d/td.repo <<'EOF';
[treasuredata]
name=TreasureData
baseurl=https://packages.treasuredata.com/4/amazon/\$releasever/\$basearch
gpgcheck=1
gpgkey=https://packages.treasuredata.com/GPG-KEY-td-agent
EOF

            ;;
        *)
            cat >/etc/yum.repos.d/td.repo <<'EOF';
[treasuredata]
name=TreasureData
baseurl=https://packages.treasuredata.com/4/redhat/\$releasever/\$basearch
gpgcheck=1
gpgkey=https://packages.treasuredata.com/GPG-KEY-td-agent
EOF
            ;;
    esac
    ${DNF} update -y
    ${DNF} install -y td-agent
    # equivalent to tmpfiles.d
    mkdir -p /tmp/fluent
    ${DNF} install -y \
           ${repositories_dir}/${distribution}/${DISTRIBUTION_VERSION}/x86_64/Packages/*.rpm

    getent passwd td-agent >/dev/null
    getent group td-agent >/dev/null
    getent passwd fluentd >/dev/null
    getent group fluentd >/dev/null
    test -h /var/log/td-agent
    test -h /etc/td-agent
    test -h /usr/sbin/td-agent
    test -h /usr/sbin/td-agent-gem

    homedir=$(getent passwd fluentd | cut -d: -f6)
    test "$homedir" = "/var/lib/fluent"

    loginshell=$(getent passwd fluentd | cut -d: -f7)
    test "$loginshell" = "/sbin/nologin"
fi
