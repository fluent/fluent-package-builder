#!/bin/bash

set -exu

distribution=$(cat /etc/system-release-cpe | awk '{print substr($0, index($1, "o"))}' | cut -d: -f2)
version=$(cat /etc/system-release-cpe | awk '{print substr($0, index($1, "o"))}' | cut -d: -f4)

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
    esac
    ;;
  rocky|almalinux)
    DNF=dnf
    DISTRIBUTION_VERSION=$(echo ${version} | cut -d. -f1)
    ;;
esac

sudo ${DNF} install -y \
  /vagrant/${distribution}/${DISTRIBUTION_VERSION}/x86_64/Packages/*.rpm

! systemctl status fluentd
sudo systemctl enable --now fluentd
systemctl status fluentd

sleep 3
! grep -q -e '\[warn\]' -e '\[error\]' -e '\[fatal\]' /var/log/fluent/fluentd.log

sudo ${DNF} remove -y fluent-package

! systemctl status fluentd
