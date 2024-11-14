#!/bin/bash

#
# Usage: test-verify-repo.sh 5.0.3
#
# It try to verify whether fluent-package is installable or not
# from test/experimental/5, test/experimental/lts/5
#

function test_deb() {
    for d in $DEB_TARGETS; do
	if [ $d = "dummy" ]; then
	    continue
	fi
	for r in $REPO_TARGETS; do
	    echo "TEST: on $d $r"
	    LOG=install-${d/:/-}-on-${r//\//-}.log
	    docker run --rm -v $(pwd):/work $d /work/test-install-in-docker.sh $USER $r $VERSION 2>&1 | tee $LOG
	    if [ ${PIPESTATUS[0]} -eq 0 ]; then
		RESULTS="$RESULTS\nOK: $d $r"
	    else
		RESULTS="$RESULTS\nNG: $d $r"
	    fi
	done
    done
}

function test_rpm() {
    for d in $RPM_TARGETS; do
	if [ $d = "dummy" ]; then
	    continue
	fi
	for r in $REPO_TARGETS; do
	    echo "TEST: on $d $r"
	    LOG=install-${d/:/-}-on-${r//\//-}.log
	    docker run --rm -v $(pwd):/work $d /work/test-install-in-docker.sh $USER $r $VERSION 2>&1 | tee $LOG
	    if [ ${PIPESTATUS[0]} -eq 0 ]; then
		RESULTS="$RESULTS\nOK: $d $r"
	    else
		RESULTS="$RESULTS\nNG: $d $r"
	    fi
	done
    done
}

if [ $# -ne 1 ]; then
    echo "Usage: test-verify-repo 5.0.3"
    exit 1
fi

VERSION=$1

if [ -z "$DEB_TARGETS" ]; then
    DEB_TARGETS="debian:bullseye debian:bookworm ubuntu:focal ubuntu:jammy ubuntu:noble"
fi
if [ -z "$RPM_TARGETS" ]; then
    RPM_TARGETS="centos:7 almalinux:8 rockylinux:9 amazonlinux:2 amazonlinux:2023"
fi
if [ -z "$REPO_TARGETS" ]; then
    REPO_TARGETS="exp/5 exp/lts/5"
fi

echo "DEB_TARGETS: $DEB_TARGETS"
echo "RPM_TARGETS: $RPM_TARGETS"
echo "REPO_TARGETS: $REPO_TARGETS"
# give a grace period to terminate (Ctrl+C)
sleep 3
RESULTS=""
test_deb
test_rpm
grep "Failed to install" install-*.log
echo -e $RESULTS
