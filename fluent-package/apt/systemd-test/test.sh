#!/bin/bash

if [ $# -lt 2 ]; then
    echo "Error: Need to specify lxc image name and filename."
    echo "Ex. CI) $ ./test.sh ubuntu:20.04 install-newly.sh local"
    exit 1
fi

image=$1
test_file=$2
shift 2
other_args="$@"
dir="/host/fluent-package/apt/systemd-test"

set -eux

echo "::group::Run test: launch $image"
lxc launch $image target --debug
sleep 5
echo "::endgroup::"
echo "::group::Run test: configure $image"
lxc config device add target host disk source=$PWD path=/host
lxc list
echo "::endgroup::"
echo "::group::Run test: setup $image"
lxc exec target -- $dir/setup.sh
echo "::endgroup::"
echo "::group::Run test: $test_file $other_args on $image"
lxc exec target -- $dir/$test_file $other_args
echo "::endgroup::"
echo "::group::Run test: cleanup $image"
lxc stop target
lxc delete target
echo "::endgroup::"
echo -e "\nAll Success!\n"
