#!/bin/bash

set -exu

echo "CHECK PACKAGE SIZE"

#
# Usage: $0 centos:8 aarch64
#
DISTRIBUTION=$(echo $1 | cut -d- -f1)
VERSION=$(echo $1 | cut -d- -f2,3)
ARCH=$2

REPOSITORIES_DIR=td-agent/yum/repositories

git fetch --unshallow
PREVIOUS_VERSION=`git describe --abbrev=0 --tags | sed -e 's/v//'`
PREVIOUS_RPM=${REPOSITORIES_DIR}/${DISTRIBUTION}/${VERSION}/${ARCH}/Packages/td-agent-${PREVIOUS_VERSION}*.rpm

SKIP_SIZE_COMPARISON=0
case ${DISTRIBUTION} in
    amazonlinux)
	BASE_URI=http://packages.treasuredata.com.s3.amazonaws.com/4/amazon/2
	BASE_NAME=td-agent-${PREVIOUS_VERSION}-1.amzn2.${ARCH}.rpm
	PREVIOUS_RPM=${BASE_URI}/${ARCH}/${BASE_NAME}
	wget ${PREVIOUS_RPM}
	DISTRIBUTION=amazon
	;;
    centos)
	case $VERSION in
	    stream-8)
		SKIP_SIZE_COMPARISON=1
		VERSION=8-stream
		;;
	    *)
		BASE_URI=http://packages.treasuredata.com.s3.amazonaws.com/4/redhat/${VERSION}
		BASE_NAME=td-agent-${PREVIOUS_VERSION}-1.el${VERSION}.${ARCH}.rpm
		PREVIOUS_RPM=${BASE_URI}/${ARCH}/${BASE_NAME}
		wget ${PREVIOUS_RPM}
		;;
	esac
	;;
esac

if [ $SKIP_SIZE_COMPARISON -eq 1 ]; then
    RPM=$(find $REPOSITORIES_DIR/${DISTRIBUTION}/${VERSION}/${ARCH}/Packages/td-agent-*.rpm -not -name '*debuginfo*' -not -name '*debugsource*' | sort -n | tail -1)
    CURRENT_SIZE=$(stat -c %s $RPM)
    CURRENT_SIZE_MIB=$(echo "scale=2; ${CURRENT_SIZE} / 1024 / 1024" | bc)
    echo "NEW: ${CURRENT_SIZE_MIB} MiB (${CURRENT_SIZE}) : ${RPM}"
    exit 0
fi

PREVIOUS_SIZE=$(stat -c %s $BASE_NAME)
THRESHOLD_SIZE=`echo "$PREVIOUS_SIZE * 1.2" | bc -l | cut -d. -f1`
find $REPOSITORIES_DIR/${DISTRIBUTION} -name td-agent-*.rpm
RPM=$(find $REPOSITORIES_DIR/${DISTRIBUTION}/${VERSION}/${ARCH}/Packages/td-agent-*.rpm -not -name '*debuginfo*' -not -name '*debugsource*' | sort -n | tail -1)
CURRENT_SIZE=$(stat -c %s $RPM)

PREVIOUS_SIZE_MIB=$(echo "scale=2; ${PREVIOUS_SIZE} / 1024 / 1024" | bc)
CURRENT_SIZE_MIB=$(echo "scale=2; ${CURRENT_SIZE} / 1024 / 1024" | bc)
echo "OLD: ${PREVIOUS_SIZE_MIB} MiB ${PREVIOUS_SIZE} : ${BASE_NAME}"
echo "NEW: ${CURRENT_SIZE_MIB} MiB (${CURRENT_SIZE}) : ${RPM}"
if [ $CURRENT_SIZE -gt $THRESHOLD_SIZE ]; then
    echo "${RPM} size exceeds ${THRESHOLD_SIZE}. Check whether needless file is bundled or not"
    exit 1
fi
