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
(! grep -e '\[warn\]' -e '\[error\]' -e '\[fatal\]' /var/log/fluent/fluentd.log)

# Test: fluent-diagtool
if [ $1 = "local" ]; then
    # Test v5 and lts too after v5.0.3 has been released.
    sudo fluent-gem install fluent-plugin-concat
    # v5.0.2 or older version doesn't depends on missing tar explicitly
    sudo $DNF install -y tar findutils
    sudo /opt/fluent/bin/fluent-diagtool -t fluentd -o /tmp
    test $(find /tmp/ -name gem_local_list.output | xargs cat) = "fluent-plugin-concat"
fi

# Test: Guard duplicated instance
(! sudo /usr/sbin/fluentd)
(! sudo /usr/sbin/fluentd -v)
sudo /usr/sbin/fluentd --dry-run

sudo $DNF remove -y fluent-package
sudo systemctl daemon-reload

getent passwd fluentd >/dev/null
getent group fluentd >/dev/null
# `sudo systemctl daemon-reload` clears the service completely.
#   (The result of `systemctl status` will be `unfound`)
# Note: RPM does not leave links like `@/etc/systemd/system/fluentd.service`.
#   (Different from deb)

(! systemctl status --no-pager fluentd)

