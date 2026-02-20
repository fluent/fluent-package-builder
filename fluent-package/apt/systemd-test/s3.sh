#!/bin/bash

set -exu

. $(dirname $0)/../commonvar.sh

# Install the current
sudo apt install -V -y \
    /host/${distribution}/pool/${code_name}/${channel}/*/*/fluent-package_*_${architecture}.deb
systemctl stop --no-pager fluentd

install_aws_cli

# Overwrite with s3.conf
GATEWAY=$(ip route | grep default | cut -d' ' -f3)
sed -e "s/127.0.0.1/${GATEWAY}/" /host/fluent-package/apt/systemd-test/s3.conf | sudo tee /etc/fluent/fluentd.conf

# Check container => host localstack connectivity
curl http://${GATEWAY}:4566/_localstack/health

sudo systemctl enable --now fluentd
systemctl status --no-pager fluentd

# wait loading sample data
sleep 20

# Check existence of .json in localstack-bucket
count=$(AWS_ACCESS_KEY_ID=localstack-test AWS_SECRET_ACCESS_KEY=localstack-test aws --endpoint-url=http://${GATEWAY}:4566 s3 ls localstack-bucket | grep -c json)
test $count -ge 1
