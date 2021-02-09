#!/bin/bash

set -exu

echo "CHECK PACKAGE SIZE"

#
# Usage: $0 ubuntu:focal aarch64
#

. $(dirname $0)/commonvar.sh

DISTRIBUTION=$(echo $1 | cut -d- -f1)
CODE_NAME=$(echo $1 | cut -d- -f2)
ARCH=$2

REPOSITORIES_DIR=td-agent/apt/repositories

git fetch --unshallow
PREVIOUS_VERSION=`git describe --abbrev=0 --tags | sed -e 's/v//'`
PREVIOUS_DEB=${REPOSITORIES_DIR}/${DISTRIBUTION}/${CODE_NAME}/pool/contrib/t/td-agent/td-agent_${PREVIOUS_VERSION}_${ARCH}.deb

case ${DISTRIBUTION} in
    debian)
	BASE_URI=http://packages.treasuredata.com.s3.amazonaws.com/4/debian/${CODE_NAME}
	BASE_NAME=td-agent_${PREVIOUS_VERSION}-1_${ARCH}.deb
	PREVIOUS_DEB=${BASE_URI}/pool/contrib/t/td-agent/${BASE_NAME}
	CHANNEL=main
	wget ${PREVIOUS_DEB}
	;;
    ubuntu)
	BASE_URI=http://packages.treasuredata.com.s3.amazonaws.com/4/ubuntu/${CODE_NAME}
	BASE_NAME=td-agent_${PREVIOUS_VERSION}-1_${ARCH}.deb
	PREVIOUS_DEB=${BASE_URI}/pool/contrib/t/td-agent/${BASE_NAME}
	CHANNEL=universe
	wget ${PREVIOUS_DEB}
	;;
esac

PREVIOUS_SIZE=$(stat -c %s $BASE_NAME)
THRESHOLD_SIZE=`echo "$PREVIOUS_SIZE * 1.2" | bc -l | cut -d. -f1`
find $REPOSITORIES_DIR/${DISTRIBUTION} -name td-agent_*${ARCH}.deb
DEB=$(find $REPOSITORIES_DIR/${DISTRIBUTION}/pool/${CODE_NAME}/${CHANNEL}/t/td-agent/td-agent_*${ARCH}.deb | sort -n | tail -1)
CURRENT_SIZE=$(stat -c %s $DEB)

PREVIOUS_SIZE_MIB=$(echo "scale=2; ${PREVIOUS_SIZE} / 1024 / 1024" | bc)
CURRENT_SIZE_MIB=$(echo "scale=2; ${CURRENT_SIZE} / 1024 / 1024" | bc)
echo "OLD: ${PREVIOUS_SIZE_MIB} MiB (${PREVIOUS_SIZE}) : ${BASE_NAME}"
echo "NEW: ${CURRENT_SIZE_MIB} MiB (${CURRENT_SIZE}) : ${DEB}"
if [ $CURRENT_SIZE -gt $THRESHOLD_SIZE ]; then
    echo "${DEB} size (${CURRENT_SIZE}) exceeds ${THRESHOLD_SIZE}. Check whether needless file is bundled or not"
    exit 1
fi
