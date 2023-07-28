#!/bin/bash

if [ -z $1 ]; then
    echo "Error: Need to specify VM name in the Vagrantfile."
    echo "Ex.) $ ./test.sh ubuntu-focal"
    exit 1
fi

vm=$1
dir="/vagrant/fluent-package/apt/systemd-test"

vagrant status $vm | grep -E "^${vm}\s+not created (.*)$"
if [ $? -ne 0 ]; then
    echo "Error: The VM already exists. Need to destroy it in advance with the following command."
    echo "$ vagrant destroy $vm"
    exit 1
fi

set -eu

test_filenames=(
    update-from-v4.sh
    update-to-next-version.sh
)

for apt_repo_type in local v5 lts; do
    echo -e "\nRun test: $apt_repo_type\n"
    vagrant up $vm
    vagrant ssh $vm -- $dir/setup.sh
    vagrant ssh $vm -- $dir/install_newly.sh $apt_repo_type
    vagrant destroy -f $vm
done

for test_filename in ${test_filenames[@]}; do
    echo -e "\nRun test: $test_filename\n"
    vagrant up $vm
    vagrant ssh $vm -- $dir/setup.sh
    vagrant ssh $vm -- $dir/$test_filename
    vagrant destroy -f $vm
    # I want to use snapshot instead of destorying it for every test,
    # but somehow, it will be often an error on GitHub Actions...
    #   $ vagrant ssh $vm -- $dir/setup.sh
    #   $ vagrant snapshot save -f $vm after-setup
    #   (execute a test)
    #   $ vagrant snapshot restore $vm after-setup
done

echo -e "\nAll Success!\n"
