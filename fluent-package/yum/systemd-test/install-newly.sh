#!/bin/bash

set -exu

. $(dirname $0)/commonvar.sh

case $1 in
  local)
    sudo $DNF install -y \
      /host/${distribution}/${DISTRIBUTION_VERSION}/x86_64/Packages/fluent-package-[0-9]*.rpm
    ;;
  v5)
    case $DISTRIBUTION in
      amazon)
        curl --fail --silent --show-error --location \
             https://toolbelt.treasuredata.com/sh/install-${DISTRIBUTION}${DISTRIBUTION_VERSION}-fluent-package5.sh | sh
        ;;
      *)
        curl --fail --silent --show-error --location \
             https://toolbelt.treasuredata.com/sh/install-redhat-fluent-package5.sh | sh
        ;;
    esac
    ;;
  lts)
    case $DISTRIBUTION in
      amazon)
        curl --fail --silent --show-error --location \
             https://toolbelt.treasuredata.com/sh/install-${DISTRIBUTION}${DISTRIBUTION_VERSION}-fluent-package5-lts.sh | sh
        ;;
      *)
        curl --fail --silent --show-error --location \
             https://toolbelt.treasuredata.com/sh/install-redhat-fluent-package5-lts.sh | sh
        ;;
    esac
    ;;
esac

(! systemctl status --no-pager fluentd)
sudo systemctl enable --now fluentd
systemctl status --no-pager fluentd

sleep 3
test -e /var/log/fluent/fluentd.log
cat /var/log/fluent/fluentd.log
(! grep -q -e '\[warn\]' -e '\[error\]' -e '\[fatal\]' /var/log/fluent/fluentd.log)

# Test: Guard duplicated instance
if [ "$1" = "local" ]; then
    # FIXME: until v5.0.3 was released, skip v5 and lts.
    (! sudo /usr/sbin/fluentd)
    (! sudo /usr/sbin/fluentd -c /etc/fluent/fluentd.conf)
    (! sudo /opt/fluent/bin/fluentd -c /etc/fluent/fluentd.conf)
fi

sudo $DNF remove -y fluent-package
sudo systemctl daemon-reload

getent passwd fluentd >/dev/null
getent group fluentd >/dev/null
# `sudo systemctl daemon-reload` clears the service completely.
#   (The result of `systemctl status` will be `unfound`)
# Note: RPM does not leave links like `@/etc/systemd/system/fluentd.service`.
#   (Different from deb)

(! systemctl status --no-pager fluentd)
