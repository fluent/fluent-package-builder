#!/bin/bash

set -exu

. $(dirname $0)/../commonvar.sh

# Install v5 LTS to register the repository
curl --fail --silent --show-error --location https://toolbelt.treasuredata.com/sh/install-${distribution}-${code_name}-fluent-package5-lts.sh | sh

sudo apt purge -y fluent-package

# Install the current
sudo apt install -V -y \
    /host/${distribution}/pool/${code_name}/${channel}/*/*/fluent-package_*_${architecture}.deb

# Test: service status
systemctl status --no-pager fluentd
systemctl status --no-pager td-agent
main_pid=$(eval $(systemctl show td-agent --property=MainPID) && echo $MainPID)

# Downgrade to v5 LTS
apt install -V -y fluent-package=${fluent_package_lts_version}-1 --allow-downgrades

systemctl status --no-pager fluentd
systemctl status --no-pager td-agent

# Fluentd should be restarted.
# NOTE: Unlike RPM, the restart behavior depends on TO-side. So, it restarts.
test $main_pid -ne $(eval $(systemctl show fluentd --property=MainPID) && echo $MainPID)
