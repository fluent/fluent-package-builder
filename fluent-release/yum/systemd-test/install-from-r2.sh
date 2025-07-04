#!/bin/bash

set -exu

. $(dirname $0)/../../../fluent-package/yum/systemd-test/commonvar.sh

sudo $DNF install -y \
     /host/${distribution}/${DISTRIBUTION_VERSION}/x86_64/Packages/fluent-release-*.noarch.rpm

test -f /etc/pki/rpm-gpg/RPM-GPG-KEY-td-agent
test -f /etc/pki/rpm-gpg/RPM-GPG-KEY-fluent-package

test -f /etc/yum.repos.d/fluent-package.repo
grep fluentd.cdn.cncf.io /etc/yum.repos.d/fluent-package.repo
# .repo file is disabled by default
test $($DNF config-manager --dump fluent-package-v6 | grep --count "enabled = 1") = 1
test $($DNF config-manager --dump fluent-package-v6-lts | grep --count "enabled = 1") = 0
test $($DNF config-manager --dump fluent-package-v5 | grep --count "enabled = 1") = 0
test $($DNF config-manager --dump fluent-package-v5-lts | grep --count "enabled = 1") = 0

# TODO: v6 package was released, remove it and test with v6
sudo $DNF config-manager --disable fluent-package-v6
sudo $DNF config-manager --enable fluent-package-v5

sudo $DNF update -y
sudo $DNF install -y fluent-package
