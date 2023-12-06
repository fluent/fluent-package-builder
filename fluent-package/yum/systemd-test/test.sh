#!/bin/bash

if [ -z $1 ]; then
    echo "Error: Need to specify distribution name."
    echo "Ex.) $ ./test.sh centos-7"
    exit 1
fi

image=$1
dir="/host/fluent-package/yum/systemd-test"

set -eux

test_filenames=(
    update-from-v4.sh
    update-to-next-version.sh
    update-to-next-version-with-backward-compat-for-v4.sh
)

for yum_repo_type in local v5 lts; do
    echo -e "\nRun test: $yum_repo_type\n"
    lxc launch $image target
    sleep 5
    lxc config device add target host disk source=$PWD path=/host
    lxc list
    lxc exec target -- $dir/install-newly.sh $yum_repo_type
    lxc stop target
    lxc delete target
done

for test_filename in ${test_filenames[@]}; do
    echo -e "\nRun test: $test_filename\n"
    lxc launch $image target
    sleep 5
    lxc config device add target host disk source=$PWD path=/host
    lxc list
    lxc exec target -- $dir/$test_filename
    lxc stop target
    lxc delete target
done

echo -e "\nAll Success!\n"
