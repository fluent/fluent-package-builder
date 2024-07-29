#!/bin/bash

set -exu

# Amazon Linux 2 system-release-cpe is:
# cpe:2.3:o:amazon:amazon_linux:2
# CentOS 7 system-release-cpe is:
# cpe:/o:centos:centos:7
# This means that column glitch exists.
# So, we should remove before "o" character.

echo "BINSTUBS TEST"
if [ "$CI" = "true" ]; then
   echo "::group::Setup binstubs test"
fi

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
    DNF=dnf
    DISTRIBUTION_VERSION=$(echo ${version} | cut -d. -f1)
    ;;
esac

repositories_dir=/fluentd/fluent-package/yum/repositories
ARCH=$(rpm --eval "%{_arch}")
${DNF} install -y \
  ${repositories_dir}/${distribution}/${DISTRIBUTION_VERSION}/${ARCH}/Packages/*.rpm

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
