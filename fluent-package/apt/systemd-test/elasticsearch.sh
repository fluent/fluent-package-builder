#!/bin/bash

set -exu

. $(dirname $0)/../commonvar.sh

GATEWAY=$(ip route | grep default | cut -d' ' -f3)

# install latest fluent-package
sudo apt install -V -y \
  /host/${distribution}/pool/${code_name}/${channel}/*/*/fluent-package_*_${architecture}.deb
sudo $DNF install -y jq

(! systemctl status --no-pager fluentd)

# Overwrite with s3.conf
sed -e "s/localhost/${GATEWAY}/" /host/fluent-package/apt/systemd-test/elasticsearch.conf > /tmp/elasticsearch.conf
sudo cp /tmp/elasticsearch.conf /etc/fluent/fluentd.conf
cat /etc/fluent/fluentd.conf

curl --silent "http://${GATEWAY}:9200/_cat/indices?v"

sudo systemctl enable --now fluentd
systemctl status --no-pager fluentd

# wait loading sample data
until curl --silent "http://${GATEWAY}:9200/_cat/indices?v" | grep -c 'fluentd-test'; do
    sleep 10
done

count=$(curl --silent "http://${GATEWAY}:9200/_search?q=message:hello&pretty" | jq ".hits.hits | length")
test $count -gt 0
