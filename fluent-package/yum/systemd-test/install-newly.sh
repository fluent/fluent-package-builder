#!/bin/bash

set -exu

. $(dirname $0)/commonvar.sh

sudo $DNF install -y \
    /vagrant/${distribution}/${DISTRIBUTION_VERSION}/x86_64/Packages/fluent-package-[0-9]*.rpm

(! systemctl status --no-pager fluentd)
sudo systemctl enable --now fluentd
systemctl status --no-pager fluentd

sleep 3
test -e /var/log/fluent/fluentd.log
(! grep -q -e '\[warn\]' -e '\[error\]' -e '\[fatal\]' /var/log/fluent/fluentd.log)

sudo $DNF remove -y fluent-package
sudo systemctl daemon-reload

# `sudo systemctl daemon-reload` clears the service completely.
#   (The result of `systemctl status` will be `unfound`)
# Note: RPM does not leave links like `@/etc/systemd/system/fluentd.service`.
#   (Different from deb)

(! systemctl status --no-pager fluentd)
