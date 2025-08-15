#!/bin/bash

set -exu

. $(dirname $0)/commonvar.sh

package="/host/${distribution}/${DISTRIBUTION_VERSION}/x86_64/Packages/fluent-package-*.rpm"

# Install the current
sudo $DNF install -y $package

# Install obsoleted plugins
sudo fluent-gem install fluent-plugin-grep

# Launch fluentd
sudo systemctl enable --now fluentd

# Log file should contain 'fluent-plugin-grep is obsolete' line
test $(grep --count "fluent-plugin-grep is obsolete" /var/log/fluent/fluentd.log) -gt 0
