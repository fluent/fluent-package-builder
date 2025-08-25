#!/bin/bash

distribution=$(cat /etc/system-release-cpe | awk '{print substr($1, index($1, "o"))}' | cut -d: -f2)
version=$(cat /etc/system-release-cpe | awk '{print substr($1, index($1, "o"))}' | cut -d: -f4)
td_agent_version=4.5.2
fluent_package_lts_version=5.0.5

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

function install_current()
{
  sudo $DNF install -y "/host/$distribution/$DISTRIBUTION_VERSION/x86_64/Packages/"fluent-package-[0-9]*.rpm
}


function install_v4()
{
  case "$DISTRIBUTION" in
    amazon)
      curl --fail --silent --show-error --location \
        https://toolbelt.treasuredata.com/sh/install-amazon2-td-agent4.sh | sh
      ;;
    *)
      curl --fail --silent --show-error --location \
        https://toolbelt.treasuredata.com/sh/install-redhat-td-agent4.sh | sh
      ;;
  esac
}

function install_v5()
{
  case "$DISTRIBUTION" in
    amazon)
      case "$DISTRIBUTION_VERSION" in
        2023)
          curl --fail --silent --show-error --location \
            https://toolbelt.treasuredata.com/sh/install-amazon2023-fluent-package5.sh | sh
          ;;
        2)
          curl --fail --silent --show-error --location \
            https://toolbelt.treasuredata.com/sh/install-amazon2-fluent-package5.sh | sh
          ;;
      esac
      ;;
    *)
      curl --fail --silent --show-error --location \
        https://toolbelt.treasuredata.com/sh/install-redhat-fluent-package5.sh | sh
      ;;
  esac
}

function install_v5_lts()
{
  case "$DISTRIBUTION" in
    amazon)
      case "$DISTRIBUTION_VERSION" in
        2023)
          curl --fail --silent --show-error --location \
            https://toolbelt.treasuredata.com/sh/install-amazon2023-fluent-package5-lts.sh | sh
          ;;
        2)
          curl --fail --silent --show-error --location \
            https://toolbelt.treasuredata.com/sh/install-amazon2-fluent-package5-lts.sh | sh
          ;;
      esac
      ;;
    *)
      curl --fail --silent --show-error --location \
        https://toolbelt.treasuredata.com/sh/install-redhat-fluent-package5-lts.sh | sh
      ;;
  esac
}

function install_v6()
{
  case "$DISTRIBUTION" in
    amazon)
      case "$DISTRIBUTION_VERSION" in
        2023)
          curl --fail --silent --show-error --location \
            https://toolbelt.treasuredata.com/sh/install-amazon2023-fluent-package6.sh | sh
          ;;
        2)
          curl --fail --silent --show-error --location \
            https://toolbelt.treasuredata.com/sh/install-amazon2-fluent-package6.sh | sh
          ;;
      esac
      ;;
    *)
      curl --fail --silent --show-error --location \
        https://toolbelt.treasuredata.com/sh/install-redhat-fluent-package6.sh | sh
      ;;
  esac
}
