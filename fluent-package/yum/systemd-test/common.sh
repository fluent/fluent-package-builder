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
            https://fluentd.cdn.cncf.io/sh/install-amazon2023-fluent-package6.sh | sh
          ;;
      esac
      ;;
    *)
      curl --fail --silent --show-error --location \
        https://fluentd.cdn.cncf.io/sh/install-redhat-fluent-package6.sh | sh
      ;;
  esac
}

function install_v6_lts()
{
  case "$DISTRIBUTION" in
    amazon)
      case "$DISTRIBUTION_VERSION" in
        2023)
          curl --fail --silent --show-error --location \
            https://fluentd.cdn.cncf.io/sh/install-amazon2023-fluent-package6-lts.sh | sh
          ;;
      esac
      ;;
    *)
      curl --fail --silent --show-error --location \
        https://fluentd.cdn.cncf.io/sh/install-redhat-fluent-package6-lts.sh | sh
      ;;
  esac
}

function install_aws_cli()
{
    ARCH=$(rpm --eval '%{_arch}')
    case $ARCH in
        x86_64)
            curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
            ;;
        arm*)
            curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
            ;;
        *)
            ;;
    esac
    sudo $DNF install -y unzip
    unzip awscliv2.zip
    sudo ./aws/install
}

function fixup_broken_mirrors()
{
    if [ "$DISTRIBUTION" = "amazon" ]; then
        return 0
    fi

    # When mirrorlist in .repo is not accessible temporary,
    # CI stops unexpectedly. This is last resort that I hope it will not fire.
    if ! sudo $DNF repolist -v; then
        # Avoid broken mirrorlist, enable baseurl explicitly
        case $DISTRIBUTION_VERSION in
            8)
                # install missing dnf-config-manager
                FALLBACK_URL=https://ftp.iij.ad.jp/pub/linux/rocky
                sudo $DNF install -y dnf-plugins-core --setopt=baseos.mirrorlist= \
                     --setopt=baseos.baseurl=${FALLBACK_URL}/\$releasever/BaseOS/\$basearch/os/

                sudo $DNF config-manager --setopt=baseos.mirrorlist= \
                     --setopt=baseos.baseurl=${FALLBACK_URL}/\$releasever/BaseOS/\$basearch/os/ --save
                sudo $DNF config-manager --setopt=appstream.mirrorlist= \
                     --setopt=appstream.baseurl=${FALLBACK_URL}/\$releasever/AppStream/\$basearch/os/ --save
                sudo $DNF config-manager --setopt=extras.mirrorlist= \
                     --setopt=extras.baseurl=${FALLBACK_URL}/\$releasever/extras/\$basearch/os/ --save
                ;;
            9|10*)
                FALLBACK_URL=https://ftp.iij.ad.jp/pub/linux/almalinux
                sudo $DNF config-manager --setopt=baseos.mirrorlist= \
                     --setopt=baseos.baseurl=${FALLBACK_URL}/\$releasever/BaseOS/\$basearch/os/ --save
                sudo $DNF config-manager --setopt=appstream.mirrorlist= \
                     --setopt=appstream.baseurl=${FALLBACK_URL}/\$releasever/AppStream/\$basearch/os/ --save
                sudo $DNF config-manager --setopt=extras.mirrorlist= \
                     --setopt=extras.baseurl=${FALLBACK_URL}/\$releasever/extras/\$basearch/os/ --save
                case $DISTRIBUTION_VERSION in
                    10*)
                        sudo $DNF config-manager --setopt=crb.mirrorlist= \
                         --setopt=crb.baseurl=${FALLBACK_URL}/\$releasever/CRB/\$basearch/os/ --save
                        ;;
                esac
                ;;
            *)
                echo "ERROR: unsupported $DISTRIBUTION $DISTRIBUTION_VERSION"
                exit 1
                ;;
        esac
    fi
}
