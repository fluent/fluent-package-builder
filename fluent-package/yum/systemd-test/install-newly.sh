#!/bin/bash

set -exu

. $(dirname $0)/commonvar.sh

case $1 in
  local)
    sudo $DNF install -y \
      /vagrant/${distribution}/${DISTRIBUTION_VERSION}/x86_64/Packages/fluent-package-[0-9]*.rpm
    ;;
  v5)
    rpm --import https://packages.treasuredata.com/GPG-KEY-td-agent
    rpm --import https://packages.treasuredata.com/GPG-KEY-fluent-package
    sudo sh <<SCRIPT
    cat > /etc/yum.repos.d/fluent-package.repo <<'EOF';
[fluent-package]
name=Fluentd Project
baseurl=https://packages.treasuredata.com/lts/5/${distribution}/${DISTRIBUTION_VERSION}/\$basearch
gpgcheck=1
gpgkey=https://packages.treasuredata.com/GPG-KEY-td-agent
       https://packages.treasuredata.com/GPG-KEY-fluent-package
EOF
SCRIPT
    sudo $DNF install -y fluent-package
    ;;
  lts)
    rpm --import https://packages.treasuredata.com/GPG-KEY-td-agent
    rpm --import https://packages.treasuredata.com/GPG-KEY-fluent-package
    sudo sh <<SCRIPT
    cat > /etc/yum.repos.d/fluent-package-lts.repo <<'EOF';
[fluent-package]
name=Fluentd Project
baseurl=https://packages.treasuredata.com/lts/5/${distribution}/${DISTRIBUTION_VERSION}/\$basearch
gpgcheck=1
gpgkey=https://packages.treasuredata.com/GPG-KEY-td-agent
       https://packages.treasuredata.com/GPG-KEY-fluent-package
EOF
SCRIPT
    sudo $DNF install -y fluent-package
    ;;
esac

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
