#!/bin/bash

if [ -z $1 ]; then
    echo "Error: Need to specify VM name in the Vagrantfile."
    echo "Ex.) $ ./test.sh almalinux-9"
    exit 1
fi

vm=$1
dir="/vagrant/fluent-package/yum/systemd-test"

vagrant status $vm | grep -E "^${vm}\s+not created (.*)$"
if [ $? -ne 0 ]; then
    echo "Error: The VM already exists. Need to destroy it in advance with the following command."
    echo "$ vagrant destroy $vm"
    exit 1
fi

set -eu

test_filenames=(
    install-newly.sh
    update-from-v4.sh
    update-to-next-version.sh
    update-to-next-version-with-backward-compat-for-v4.sh
)

for test_filename in ${test_filenames[@]}; do
    echo -e "\nRun test: $test_filename\n"
    vagrant up $vm
    vagrant ssh $vm -- $dir/$test_filename
    vagrant destroy -f $vm
    # I want to use snapshot instead of destroying it for every test,
    # but somehow, it will be often an error on GitHub Actions...
    #   $ vagrant snapshot save -f $vm after-setup
    #   (execute a test)
    #   $ vagrant snapshot restore $vm after-setup
done

echo -e "\nAll Success!\n"
