#!/bin/bash

# Utility script to convert repository layout for packages.treasuredata.com
#
# Usage:
#
#   For https://td-agent-package-browser.herokuapp.com/5
#
#   $ convert-artifacts-layout.sh apt
#   $ convert-artifacts-layout.sh yum
#
#   For https://td-agent-package-browser.herokuapp.com/lts/5
#
#   $ convert-artifacts-layout.sh apt lts
#   $ convert-artifacts-layout.sh yum lts

set -ex

FLUENT_PACKAGE_DIR=$(dirname $(realpath $0))
REPOSITORY_TYPE=""
if [ "$2" = "lts" ]; then
    ARTIFACTS_DIR="artifacts/lts"
else
    ARTIFACTS_DIR="artifacts"
fi
case $1 in
    apt|deb)
	REPOSITORY_TYPE=apt
	REPOSITORY_PATH=$FLUENT_PACKAGE_DIR/$REPOSITORY_TYPE/repositories
	for d in bullseye bookworm focal jammy; do
	    case $d in
		bullseye|bookworm)
		    # e.g. mapping debian/pool/buster/main/t/td-agent/ => 5/debian/buster/pool/contrib/t/td-agent
		    #      mapping debian/pool/buster/main/f/fluent-package/ => 5/debian/buster/pool/contrib/f/fluent-package
		    mkdir -p $ARTIFACTS_DIR/5/debian/$d/pool/contrib/f/fluent-package
		    find $REPOSITORY_PATH/debian/pool/$d -name 'td-agent*.deb' -not -name '*dbgsym*' \
			 -exec cp {} $ARTIFACTS_DIR/5/debian/$d/pool/contrib/f/fluent-package \;
		    find $REPOSITORY_PATH/debian/pool/$d -name 'fluent-package*.deb' -not -name '*dbgsym*' \
			 -exec cp {} $ARTIFACTS_DIR/5/debian/$d/pool/contrib/f/fluent-package \;
		    if [ "$2" = "lts" ]; then
			mkdir -p $ARTIFACTS_DIR/5/debian/$d/pool/contrib/f/fluent-lts-apt-source
			find $REPOSITORY_PATH/debian/pool/$d -name 'fluent-lts-apt-source*.deb' -not -name '*dbgsym*' \
			     -exec cp {} $ARTIFACTS_DIR/5/debian/$d/pool/contrib/f/fluent-lts-apt-source \;
		    else
			mkdir -p $ARTIFACTS_DIR/5/debian/$d/pool/contrib/f/fluent-apt-source
			find $REPOSITORY_PATH/debian/pool/$d -name 'fluent*-apt-source*.deb' \
			     -not -name '*dbgsym*' \
			     -not -name 'fluent-lts*' \
			     -exec cp {} $ARTIFACTS_DIR/5/debian/$d/pool/contrib/f/fluent-apt-source \;
		    fi
		    ;;
		focal|jammy)
		    # e.g. mapping ubuntu/pool/.../main/t/td-agent/ => 5/ubuntu/.../pool/contrib/t/td-agent
		    #      mapping ubuntu/pool/.../main/f/fluent-package/ => 5/ubuntu/.../pool/contrib/f/fluent-package
		    mkdir -p $ARTIFACTS_DIR/5/ubuntu/$d/pool/contrib/f/fluent-package
		    find $REPOSITORY_PATH/ubuntu/pool/$d -name 'td-agent*.deb' \
			 -exec cp {} $ARTIFACTS_DIR/5/ubuntu/$d/pool/contrib/f/fluent-package \;
		    find $REPOSITORY_PATH/ubuntu/pool/$d -name 'fluent-package*.deb' \
			 -exec cp {} $ARTIFACTS_DIR/5/ubuntu/$d/pool/contrib/f/fluent-package \;
		    if [ "$2" = "lts" ]; then
			mkdir -p $ARTIFACTS_DIR/5/ubuntu/$d/pool/contrib/f/fluent-lts-apt-source
			find $REPOSITORY_PATH/ubuntu/pool/$d -name 'fluent-lts-apt-source*.deb' \
			     -exec cp {} $ARTIFACTS_DIR/5/ubuntu/$d/pool/contrib/f/fluent-lts-apt-source \;
		    else
			mkdir -p $ARTIFACTS_DIR/5/ubuntu/$d/pool/contrib/f/fluent-apt-source
			find $REPOSITORY_PATH/ubuntu/pool/$d -name 'fluent*-apt-source*.deb' \
			     -not -name 'fluent-lts*' \
			     -exec cp {} $ARTIFACTS_DIR/5/ubuntu/$d/pool/contrib/f/fluent-apt-source \;
		    fi
		    ;;
		*)
		    exit 1
		    ;;
	    esac
	done
	;;
    yum|rpm)
	REPOSITORY_TYPE=yum
	REPOSITORY_PATH=$FLUENT_PACKAGE_DIR/$REPOSITORY_TYPE/repositories
	for dist in centos amazon rocky almalinux; do
	    dist_dest=$dist
	    if [ $dist = "centos" -o $dist = "rocky" -o $dist = "almalinux" ]; then
		dist_dest="redhat"
	    fi
	    for release in 2 7 8 9 2023; do
		if [ $dist = "amazon" ]; then
		    if [ $release -ne 2 -a $release -ne 2023 ]; then
			echo "skip $dist:$release"
			continue
		    fi
		fi
		if [ $dist = "centos" -a $release -ne 7 ]; then
		    echo "skip $dist:$release"
		    continue
		fi
		if [ $dist = "rocky" -a $release -ne 8 ]; then
		    echo "skip $dist:$release"
		    continue
		fi
		if [ $dist = "almalinux" -a $release -ne 9 ]; then
		    echo "skip $dist:$release"
		    continue
		fi
		for arch in aarch64 x86_64; do
		    # e.g. mapping amazon/2/x86_64/Packages/ => 5/amazon/2/x86_64
		    mkdir -p $ARTIFACTS_DIR/5/$dist_dest/$release/$arch
		    find $REPOSITORY_PATH/$dist/$release/$arch -name '*.rpm' -not -name '*debug*' -exec cp {} $ARTIFACTS_DIR/5/$dist_dest/$release/$arch \;
		done
	    done
	done
	;;
esac

