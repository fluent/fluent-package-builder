#!/bin/bash

set -exu

. $(dirname $0)/commonvar.sh

# Install v5 LTS to register the repository
case $distribution in
    amazon)
        case $version in
            2023)
                curl -fsSL https://toolbelt.treasuredata.com/sh/install-amazon2023-fluent-package5-lts.sh | sh
                ;;
            2)
                curl -fsSL https://toolbelt.treasuredata.com/sh/install-amazon2-fluent-package5-lts.sh | sh
                ;;
        esac
        ;;
    *)
        curl -fsSL https://toolbelt.treasuredata.com/sh/install-redhat-fluent-package5-lts.sh | sh
        ;;
esac

sudo $DNF remove -y fluent-package

# Install the current
sudo $DNF install -y \
    /host/${distribution}/${DISTRIBUTION_VERSION}/x86_64/Packages/fluent-package-[0-9]*.rpm

# Customize the env file to prevent replacing by downgrade.
# Need this to test the case where some tmp files is left.
echo "FOO=foo" | sudo tee -a /etc/sysconfig/fluentd

sudo systemctl enable --now fluentd
systemctl status --no-pager fluentd
systemctl status --no-pager td-agent
main_pid=$(eval $(systemctl show fluentd --property=MainPID) && echo $MainPID)

# Downgrade to v5 LTS
sudo $DNF downgrade -y fluent-package-${fluent_package_lts_version}

# Test: take over enabled state
systemctl is-enabled fluentd

# Test: service status
systemctl status --no-pager fluentd
systemctl status --no-pager td-agent

# Fluentd should NOT be restarted.
# NOTE: Unlike DEB, the restart behavior depends on FROM-side. So, it does not restart.
#       (it should restarts only when triggering zerodowntime-restart).
test $main_pid -eq $(eval $(systemctl show fluentd --property=MainPID) && echo $MainPID)

# === Test: Remained tmp files should not affect to next upgrade ===
# (This happens when env file was customized but the FLUENT_PACKAGE_SERVICE_RESTART was still `auto`)

# Some tmp files remains, though it is not happy.
test -e /tmp/fluent/.install_plugins
test -e /tmp/fluent/.pid_for_auto_restart

sudo $DNF install -y \
    /host/${distribution}/${DISTRIBUTION_VERSION}/x86_64/Packages/fluent-package-[0-9]*.rpm | tee upgrade.log

# zerodowntime-restart should NOT be triggered.
(! grep "Kick auto restart" upgrade.log)

# ======
