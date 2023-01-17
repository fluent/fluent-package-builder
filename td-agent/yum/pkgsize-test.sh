#!/bin/bash

set -exu

echo "CHECK PACKAGE SIZE"

#
# Usage: $0 centos:8 aarch64
#
DISTRIBUTION=$(echo $1 | cut -d- -f1)
DISTRO_VERSION=$(echo $1 | cut -d- -f2,3)
ARCH=$2

REPOSITORIES_DIR=td-agent/yum/repositories

git fetch --unshallow
git fetch --all
PREVIOUS_VERSIONS=()
for v in `git tag | grep "^v" | sort -r`; do
    PREVIOUS_VERSIONS+=(`echo $v | sed -e 's/v//'`)
done

SKIP_SIZE_COMPARISON=0
BASE_URI=http://packages.treasuredata.com.s3.amazonaws.com/4/redhat/${DISTRO_VERSION}
DISTRO_VERSION_PREFIX=el
case ${DISTRIBUTION} in
    amazonlinux)
	BASE_URI=http://packages.treasuredata.com.s3.amazonaws.com/4/amazon/${DISTRO_VERSION}
	DISTRIBUTION=amazon
	DISTRO_VERSION_PREFIX=amzn
	if [ $DISTRO_VERSION -eq 2022 ]; then
		# FIXME: no previous release package for Amazon Linux 2022
		SKIP_SIZE_COMPARISON=1
	fi
	;;
    centos|almalinux)
	;;
    rockylinux)
	# /etc/os-release ID=rocky
	DISTRIBUTION=rocky
	;;
    *)
	echo "${DISTRIBUTION} is not supported"
	exit 1
	;;
esac

set -e
if [ $SKIP_SIZE_COMPARISON -eq 1 ]; then
    RPM=$(find $REPOSITORIES_DIR/${DISTRIBUTION}/${DISTRO_VERSION}/${ARCH}/Packages/td-agent-*.rpm -not -name '*debuginfo*' -not -name '*debugsource*' | sort -n | tail -1)
    CURRENT_SIZE=$(stat -c %s $RPM)
    CURRENT_SIZE_MIB=$(echo "scale=2; ${CURRENT_SIZE} / 1024 / 1024" | bc)
    echo "NEW: ${CURRENT_SIZE_MIB} MiB (${CURRENT_SIZE}) : ${RPM}"
    exit 0
fi

for v in "${PREVIOUS_VERSIONS[@]}"; do
    BASE_NAME=td-agent-${v}-1.${DISTRO_VERSION_PREFIX}${DISTRO_VERSION}.${ARCH}.rpm
    PREVIOUS_RPM=${BASE_URI}/${ARCH}/${BASE_NAME}
    set +e
    wget ${PREVIOUS_RPM}
    if [ $? -eq 0 ]; then
	break
    fi
done

PREVIOUS_SIZE=$(stat -c %s $BASE_NAME)
THRESHOLD_SIZE=`echo "$PREVIOUS_SIZE * 1.3" | bc -l | cut -d. -f1`
find $REPOSITORIES_DIR/${DISTRIBUTION} -name td-agent-*.rpm
RPM=$(find $REPOSITORIES_DIR/${DISTRIBUTION}/${DISTRO_VERSION}/${ARCH}/Packages/td-agent-*.rpm -not -name '*debuginfo*' -not -name '*debugsource*' | sort -n | tail -1)
CURRENT_SIZE=$(stat -c %s $RPM)

PREVIOUS_SIZE_MIB=$(echo "scale=2; ${PREVIOUS_SIZE} / 1024 / 1024" | bc)
CURRENT_SIZE_MIB=$(echo "scale=2; ${CURRENT_SIZE} / 1024 / 1024" | bc)
echo "OLD: ${PREVIOUS_SIZE_MIB} MiB ${PREVIOUS_SIZE} : ${BASE_NAME}"
echo "NEW: ${CURRENT_SIZE_MIB} MiB (${CURRENT_SIZE}) : ${RPM}"
if [ $CURRENT_SIZE -gt $THRESHOLD_SIZE ]; then
    echo "${RPM} size exceeds ${THRESHOLD_SIZE}. Check whether needless file is bundled or not"
    exit 1
fi
