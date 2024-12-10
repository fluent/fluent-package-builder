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

# Fluentd should be restarted.
test $main_pid -ne $(eval $(systemctl show fluentd --property=MainPID) && echo $MainPID)
