#!/bin/bash

set -exu

echo "CHECK PACKAGE SIZE"

if [ "$CI" = "true" ]; then
   echo "::group::Setup package size check"
fi

#
# Usage: $0 ubuntu:focal aarch64
#

. $(dirname $0)/commonvar.sh

DISTRIBUTION=$(echo $1 | cut -d- -f1)
CODE_NAME=$(echo $1 | cut -d- -f2)
ARCH=$2

REPOSITORIES_DIR=fluent-package/apt/repositories

if [ -f .git/shallow ]; then
    git fetch --unshallow
fi
git fetch --all
PREVIOUS_VERSIONS=()
for v in `git tag | grep "^v" | sort -r`; do
    PREVIOUS_VERSIONS+=(`echo $v | sed -e 's/v//'`)
done

case ${DISTRIBUTION} in
    debian)
	BASE_URI=https://packages.treasuredata.com/5/debian/${CODE_NAME}
	CHANNEL=main
	for v in "${PREVIOUS_VERSIONS[@]}"; do
	    BASE_NAME=fluent-package_${v}-1_${ARCH}.deb
	    PREVIOUS_DEB=${BASE_URI}/pool/contrib/f/fluent-package/${BASE_NAME}
	    set +e
	    wget ${PREVIOUS_DEB}
	    if [ $? -eq 0 ]; then
	       break
	    fi
	done
	;;
    ubuntu)
	BASE_URI=https://packages.treasuredata.com/5/ubuntu/${CODE_NAME}
	CHANNEL=universe
	for v in "${PREVIOUS_VERSIONS[@]}"; do
	    BASE_NAME=fluent-package_${v}-1_${ARCH}.deb
	    PREVIOUS_DEB=${BASE_URI}/pool/contrib/f/fluent-package/${BASE_NAME}
	    set +e
	    wget ${PREVIOUS_DEB}
	    if [ $? -eq 0 ]; then
		break
	    fi
	done
	;;
    *)
	echo "${DISTRIBUTION} is not supported"
	exit 1
	;;
esac

if [ "$CI" = "true" ]; then
   echo "::endgroup::"
fi

set -e

DEB=$(find $REPOSITORIES_DIR/${DISTRIBUTION}/pool/${CODE_NAME}/${CHANNEL}/f/fluent-package/fluent-package_*${ARCH}.deb | sort -n | tail -1)
CURRENT_SIZE=$(stat -c %s $DEB)
CURRENT_SIZE_MIB=$(echo "scale=2; ${CURRENT_SIZE} / 1024 / 1024" | bc)

if [ ! -e $BASE_NAME ]; then
    echo "OLD: Not found (not supported)"
    echo "NEW: ${CURRENT_SIZE_MIB} MiB (${CURRENT_SIZE}) : ${DEB}"
    exit 0
fi

PREVIOUS_SIZE=$(stat -c %s $BASE_NAME)
PREVIOUS_SIZE_MIB=$(echo "scale=2; ${PREVIOUS_SIZE} / 1024 / 1024" | bc)
THRESHOLD_SIZE=`echo "$PREVIOUS_SIZE * 1.2" | bc -l | cut -d. -f1`
echo "OLD: ${PREVIOUS_SIZE_MIB} MiB (${PREVIOUS_SIZE}) : ${BASE_NAME}"
echo "NEW: ${CURRENT_SIZE_MIB} MiB (${CURRENT_SIZE}) : ${DEB}"
if [ $CURRENT_SIZE -gt $THRESHOLD_SIZE ]; then
    echo "${DEB} size (${CURRENT_SIZE}) exceeds ${THRESHOLD_SIZE}. Check whether needless file is bundled or not"
    exit 1
fi
