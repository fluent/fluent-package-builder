#!/bin/bash

if [ -z $1 ]; then
    echo "Error: Need to specify lxc image name."
    echo "Ex.) $ ./test.sh ubuntu:20.04"
    exit 1
fi

image=$1
dir="/host/fluent-package/apt/systemd-test"

set -eux

test_filenames=(
    update-to-next-version.sh
)

if [ ! $image = "images:debian/12" ]; then
    # As no bookworm package for v4, so execute upgrade test for other code name.
    test_filenames+=(
        update-from-v4.sh
        update-to-next-version-with-backward-compat-for-v4.sh
        downgrade-to-v4.sh
    )
fi

for apt_repo_type in local v5 lts; do
    echo -e "\nRun test: $apt_repo_type\n"
    lxc launch $image target
    sleep 5
    lxc config device add target host disk source=$PWD path=/host
    lxc list
    lxc exec target -- $dir/setup.sh
    lxc exec target -- $dir/install-newly.sh $apt_repo_type
    lxc stop target
    lxc delete target
done

for test_filename in ${test_filenames[@]}; do
    echo -e "\nRun test: $test_filename\n"
    lxc launch $image target
    sleep 5
    lxc config device add target host disk source=$PWD path=/host
    lxc list
    lxc exec target -- $dir/setup.sh
    lxc exec target -- $dir/$test_filename
    lxc stop target
    lxc delete target
done

echo -e "\nAll Success!\n"
