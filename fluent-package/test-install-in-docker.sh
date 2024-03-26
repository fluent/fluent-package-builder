#!/bin/bash

set -e

#
# Intended to be invoked from test-verify-repo.sh
#
# Usage:
#   test-install-in-docker.sh $USER 5
#   test-install-in-docker.sh $USER lts/5
#   test-install-in-docker.sh $USER exp/5
#   test-install-in-docker.sh $USER exp/lts/5
#

function setup_apt_user()
{
    apt update
    apt upgrade -y
    apt install -y sudo expect curl
    useradd -m -s /bin/bash -u 1000 $USER
    expect -c "
set timeout 5
spawn env LANG=C passwd $USER
expect \"New password:\"
send: \"$USER\"
expect \"Retype new password:\"
send: \"$USER\"
exit 0
"
    gpasswd -a $USER sudo
    echo "$USER ALL=NOPASSWD: ALL" > /etc/sudoers.d/$USER
    su - $USER
}

function setup_dnf_user()
{
    $DNF update -y
    case $VERSION_ID in
	*2023*|*9\.*)
	    # curl-minimal should be used by default
	    $DNF install -y sudo expect shadow-utils passwd util-linux
	    ;;
	*)
	    $DNF install -y sudo expect curl shadow-utils passwd util-linux
	    ;;
    esac
    useradd -m -s /bin/bash -u 1000 $USER
    expect -c "
set timeout 5
spawn env LANG=C passwd $USER
expect \"New password:\"
send: \"$USER\"
expect \"Retype new password:\"
send: \"$USER\"
exit 0
"
    gpasswd -a $USER wheel
    echo "$USER ALL=NOPASSWD: ALL" > /etc/sudoers.d/$USER
    su - $USER
}

function check_installed_version()
{
    VERSION=$1
    case $VERSION in
	*$TARGET*)
	    echo "Succeeded to install $TARGET on $ID from $REPO"
	    ;;
	*)
	    echo "Failed to install $TARGET from $REPO"
	    exit 1
	    ;;
    esac
}

USER=$1
REPO=$2
TARGET=$3

DNF=dnf

ID=$(cat /etc/os-release | grep "^ID=" | cut -d'=' -f2)
case $ID in
    debian|ubuntu)
	CODENAME=$(cat /etc/os-release | grep VERSION_CODENAME | cut -d'=' -f2)
	case $CODENAME in
	    bullseye|bookworm|focal|jammy)
		setup_apt_user
		case $REPO in
		    exp/5)
			curl -fsSL https://toolbelt.treasuredata.com/sh/install-$ID-$CODENAME-fluent-package5.sh | sh
 			sudo sed -i -e 's,/5,/test/experimental/5,' /etc/apt/sources.list.d/fluent.sources
			;;
		    exp/lts/5)
			curl -fsSL https://toolbelt.treasuredata.com/sh/install-$ID-$CODENAME-fluent-package5-lts.sh | sh
			sudo sed -i -e 's,/lts/5,/test/experimental/lts/5,' /etc/apt/sources.list.d/fluent-lts.sources
 			;;
		esac
		sudo apt update
		sudo apt upgrade -y
		v=$(apt-cache show fluent-package | grep "^Version" | head -n 1 | cut -d':' -f 2)
		check_installed_version $v
		;;
	esac
	;;
    *centos*|*almalinux*|*rocky*)
	DNF=yum
	VERSION_ID=$(cat /etc/os-release | grep VERSION_ID | cut -d'=' -f2)
	setup_dnf_user
	case $REPO in
	    exp/5)
		curl -fsSL https://toolbelt.treasuredata.com/sh/install-redhat-fluent-package5.sh | sh
 		sudo sed -i -e 's,/5,/test/experimental/5,' /etc/yum.repos.d/fluent-package.repo
		;;
	    exp/lts/5)
		curl -fsSL https://toolbelt.treasuredata.com/sh/install-redhat-fluent-package5-lts.sh | sh
		sudo sed -i -e 's,/lts/5,/test/experimental/lts/5,' /etc/yum.repos.d/fluent-package-lts.repo
 		;;
	esac
	$DNF update -y
	v=$($DNF info fluent-package | grep "^Version" | head -n 1 | cut -d':' -f 2)
	check_installed_version $v
	;;
    *amzn*)
	VERSION_ID=$(cat /etc/os-release | grep VERSION_ID | cut -d'=' -f2)
	case $VERSION_ID in
	    *2023*)
		setup_dnf_user
		case $REPO in
		    exp/5)
			curl -fsSL https://toolbelt.treasuredata.com/sh/install-amazon2023-fluent-package5.sh | sh
 			sudo sed -i -e 's,/5,/test/experimental/5,' /etc/yum.repos.d/fluent-package.repo
			;;
		    exp/lts/5)
			curl -fsSL https://toolbelt.treasuredata.com/sh/install-amazon2023-fluent-package5-lts.sh | sh
			sudo sed -i -e 's,/lts/5,/test/experimental/lts/5,' /etc/yum.repos.d/fluent-package-lts.repo
			;;
		esac
		;;
	    *2*)
		DNF=yum
		setup_dnf_user
		case $REPO in
		    exp/5)
			curl -fsSL https://toolbelt.treasuredata.com/sh/install-amazon2-fluent-package5.sh | sh
 			sudo sed -i -e 's,/5,/test/experimental/5,' /etc/yum.repos.d/fluent-package.repo
			;;
		    exp/lts/5)
			curl -fsSL https://toolbelt.treasuredata.com/sh/install-amazon2-fluent-package5-lts.sh | sh
			sudo sed -i -e 's,/lts/5,/test/experimental/lts/5,' /etc/yum.repos.d/fluent-package-lts.repo
			;;
		esac
		;;
	esac
	$DNF update -y
	v=$($DNF info fluent-package | grep "^Version" | head -n 1 | cut -d':' -f 2)
	check_installed_version $v
	;;
esac
