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

distribution=$(cat /etc/system-release-cpe | awk '{print substr($0, index($1, "o"))}' | cut -d: -f2)
version=$(cat /etc/system-release-cpe | awk '{print substr($0, index($1, "o"))}' | cut -d: -f4)

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

td-agent --version
test -e /etc/logrotate.d/fluentd
test -e /opt/fluent/share/td-agent.conf.tmpl
test -e /opt/fluent/share/td-agent-ruby.conf

echo "UNINSTALL TEST"
${DNF} remove -y fluent-package

! test -e /etc/logrotate.d/fluentd
! test -e /opt/fluent/share/td-agent.conf.tmpl
! test -e /opt/fluent/share/td-agent-ruby.conf

for conf_path in /etc/td-agent/td-agent.conf /etc/fluent/fluentd.conf; do
    if [ -e $conf_path ]; then
	echo "$conf_path must be removed"
	exit 1
    fi
done

if getent passwd fluentd >/dev/null; then
    echo "fluentd user must be removed"
    exit 1
fi

if getent group fluentd >/dev/null; then
    echo "fluentd group must be removed"
    exit 1
fi

if [ $ENABLE_UPGRADE_TEST -eq 1 ]; then
    echo "UPGRADE TEST from v3"
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


    if ! getent passwd td-agent >/dev/null; then
        echo "td-agent user must exist"
        exit 1
    fi
    if ! getent group td-agent >/dev/null; then
        echo "td-agent group must exist"
        exit 1
    fi
    if ! getent passwd fluentd >/dev/null; then
        echo "fluentd user must exist"
        exit 1
    fi
    if ! getent group fluentd >/dev/null; then
        echo "fluentd group must exist"
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

    homedir=$(getent passwd fluentd | cut -d: -f6)
    if [ "$homedir" != "/var/lib/fluent" ]; then
	echo "fluentd must use /var/lib/fluent as home directory"
	exit 1
    fi

    loginshell=$(getent passwd fluentd | cut -d: -f7)
    if [ "$loginshell" != "/sbin/nologin" ]; then
	echo "fluentd must use nologin"
	exit 1
    fi
fi
