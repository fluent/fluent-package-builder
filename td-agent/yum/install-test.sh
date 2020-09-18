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
        ;;
    esac
    ;;
  centos)
    case ${version} in
      6)
        DNF=yum
        ;;
      7)
        DNF=yum
        ;;
      *)
        DNF="dnf --enablerepo=PowerTools"
        ENABLE_UPGRADE_TEST=0
        ;;
    esac
    ;;
esac

echo "INSTALL TEST"
repositories_dir=/fluentd/td-agent/yum/repositories
${DNF} install -y \
  ${repositories_dir}/${distribution}/${version}/x86_64/Packages/*.rpm

td-agent --version

echo "UNINSTALL TEST"
${DNF} remove -y td-agent

if [ $ENABLE_UPGRADE_TEST -eq 1 ]; then
    echo "UPGRADE TEST from v3"
    rpm --import https://packages.treasuredata.com/GPG-KEY-td-agent
    case ${distribution} in
        amazon)
            cat >/etc/yum.repos.d/td.repo <<'EOF';
[treasuredata]
name=TreasureData
baseurl=https://packages.treasuredata.com/3/amazon/2/\$releasever/\$basearch
gpgcheck=1
gpgkey=https://packages.treasuredata.com/GPG-KEY-td-agent
EOF

            ;;
        *)
            cat >/etc/yum.repos.d/td.repo <<'EOF';
[treasuredata]
name=TreasureData
baseurl=https://packages.treasuredata.com/3/redhat/\$releasever/\$basearch
gpgcheck=1
gpgkey=https://packages.treasuredata.com/GPG-KEY-td-agent
EOF
            ;;
    esac
    ${DNF} update -y
    ${DNF} install -y td-agent
    ${DNF} install -y \
           ${repositories_dir}/${distribution}/${version}/x86_64/Packages/*.rpm
fi
