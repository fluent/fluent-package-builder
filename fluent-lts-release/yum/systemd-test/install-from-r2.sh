#!/bin/bash

set -exu

. $(dirname $0)/../../../fluent-package/yum/systemd-test/commonvar.sh

sudo $DNF install -y \
     /host/${distribution}/${DISTRIBUTION_VERSION}/x86_64/Packages/fluent-lts-release-*.noarch.rpm

test -f /etc/pki/rpm-gpg/RPM-GPG-KEY-td-agent
test -f /etc/pki/rpm-gpg/RPM-GPG-KEY-fluent-package

test -f /etc/yum.repos.d/fluent-package-lts.repo
grep fluentd.cdn.cncf.io /etc/yum.repos.d/fluent-package-lts.repo
test $($DNF repolist --enabled | grep 'Fluentd Project' | wc -l) -eq 1
test $($DNF repolist --enabled | grep 'Fluentd Project' | cut -d' ' -f1) = fluent-package-v6-lts

# TODO: v6 package was released, remove it and test with v6
sudo $DNF config-manager --disable fluent-package-v6-lts
sudo $DNF config-manager --enable fluent-package-v5-lts

sudo $DNF update -y
sudo $DNF install -y fluent-package
