#!/bin/bash

if [ -z $1 ]; then
    echo "Error: Need to specify lxc image name."
    echo "Ex.) $ ./test.sh ubuntu:20.04 "
    echo "Ex. CI) $ ./test.sh ubuntu:20.04 install-newly.sh local"
    exit 1
fi

image=$1
test_file=$2
apt_repo_type=$3
dir="/host/fluent-package/apt/systemd-test"

set -eux

echo "::group::Run test: launch $image"
sudo incus launch $image target --debug
sleep 5
echo "::endgroup::"
echo "::group::Run test: configure $image"
sudo incus config device add target host disk source=$PWD path=/host
sudo incus list
echo "::endgroup::"
echo "::group::Run test: setup $image"
sudo incus exec target -- $dir/setup.sh
echo "::endgroup::"
echo "::group::Run test: $test_file $other_args on $image"
sudo incus exec target -- $dir/$test_file $other_args
echo "::endgroup::"
echo "::group::Run test: cleanup $image"
sudo incus stop target
sudo incus delete target
echo "::endgroup::"
echo -e "\nAll Success!\n"
