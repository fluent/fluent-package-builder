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
      6|7)
        DNF=yum
        ;;
      *)
        DNF="dnf --enablerepo=PowerTools"
        ;;
    esac
    ;;
esac

repositories_dir=/fluentd/td-agent/yum/repositories
${DNF} install -y \
  ${repositories_dir}/${distribution}/${version}/x86_64/Packages/*.rpm

td-agent --version
