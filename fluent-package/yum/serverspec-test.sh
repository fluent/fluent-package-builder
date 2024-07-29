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

if [ "$CI" = "true" ]; then
   echo "::group::Setup serverspec test"
fi

distribution=$(cat /etc/system-release-cpe | awk '{print substr($0, index($0, "o"))}' | cut -d: -f2)
version=$(cat /etc/system-release-cpe | awk '{print substr($0, index($0, "o"))}' | cut -d: -f4)

case ${distribution} in
  amazon)
    case ${version} in
      2)
        DNF=yum
        DISTRIBUTION_VERSION=${version}
        ;;
      2023)
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
    DNF=dnf
    DISTRIBUTION_VERSION=$(echo ${version} | cut -d. -f1)
    version=$DISTRIBUTION_VERSION
    case ${version} in
      9)
        # FIXME: Accept SHA-1 signed confluent packages.
        update-crypto-policies --set LEGACY
        ;;
    esac
    ;;
esac

echo "INSTALL TEST"
repositories_dir=/fluentd/fluent-package/yum/repositories
${DNF} install -y \
  ${repositories_dir}/${distribution}/${DISTRIBUTION_VERSION}/x86_64/Packages/*.rpm

fluentd --version

/usr/sbin/fluent-gem install --no-document serverspec
export PATH=/opt/fluent/bin:$PATH
export INSTALLATION_TEST=true
cd /fluentd && rake serverspec:linux
