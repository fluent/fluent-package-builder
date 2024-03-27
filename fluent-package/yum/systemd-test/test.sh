#!/bin/bash

if [ -z $1 ]; then
    echo "Error: Need to specify distribution name."
    echo "Ex.) $ ./test.sh centos-7"
    echo "Ex.CI) $ ./test.sh centos-7 install-newly.sh local"
    exit 1
fi

image=$1
test_file=$2
yum_repo_type=$3
dir="/host/fluent-package/yum/systemd-test"
set -eux

echo "::group::Run test: launch $image"
lxc launch $image target
sleep 5
echo "::endgroup::"
echo "::group::Run test: configure $image"
lxc config device add target host disk source=$PWD path=/host
lxc list
echo "::endgroup::"
echo "::group::Run test: $test_file $yum_repo_type on $image"
lxc exec target -- $dir/$test_file $yum_repo_type
echo "::endgroup::"
echo "::group::Run test: cleanup $image"
lxc stop target
lxc delete target
echo "::endgroup::"
echo -e "\nAll Success!\n"
