#!/bin/bash

distribution=$(cat /etc/system-release-cpe | awk '{print substr($0, index($1, "o"))}' | cut -d: -f2)
version=$(cat /etc/system-release-cpe | awk '{print substr($0, index($1, "o"))}' | cut -d: -f4)

case $distribution in
  amazon)
    case $version in
      2)
        DNF=yum
        DISTRIBUTION_VERSION=$version
        ;;
      2023)
        DNF=dnf
        DISTRIBUTION_VERSION=$version
        ;;
    esac
    DISTRIBUTION=amazon
    ;;
  centos)
    case $version in
      7)
        DNF=yum
        DISTRIBUTION_VERSION=$version
        ;;
    esac
    DISTRIBUTION=redhat
    ;;
  rocky|almalinux)
    DNF=dnf
    DISTRIBUTION=redhat
    DISTRIBUTION_VERSION=$(echo $version | cut -d. -f1)
    ;;
esac
