#!/bin/bash

set -exu

. $(dirname $0)/../commonvar.sh

package="/host/${distribution}/pool/${code_name}/${channel}/*/*/fluent-package_*_${architecture}.deb"

# Install the current
sudo apt install -V -y $package

# Install obsoleted plugins
sudo fluent-gem install fluent-plugin-grep

# Launch fluentd
sudo systemctl restart fluentd

# Log file should contain 'fluent-plugin-grep is obsolete' line
test $(grep --count "fluent-plugin-grep is obsolete" /var/log/fluent/fluentd.log) -gt 0
