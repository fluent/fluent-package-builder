#!/bin/bash

set -exu

sudo apt update
# Setup apt-eatmydata equivalent configuration
sudo apt install -y eatmydata
sudo ln -s /usr/bin/eatmydata /usr/local/bin/dpkg
sudo tee /etc/apt/apt.conf.d/25-eatmydata-action << 'EOF'
Dir::Bin::dpkg "/usr/local/bin/dpkg";
EOF
sudo apt install -V -y lsb-release curl
