#!/bin/bash

set -exu

. $(dirname $0)/../commonvar.sh

GATEWAY=$(ip route | grep default | cut -d' ' -f3)

find /host/${distribution} -name '*.deb'

# install latest fluent-package
sudo apt install -V -y \
  /host/${distribution}/pool/${code_name}/${channel}/*/*/fluent-package_*_${architecture}.deb
sudo apt install -y jq

systemctl status --no-pager fluentd
sudo systemctl stop fluentd

# Overwrite with opensearch.conf
sed -e "s/localhost/${GATEWAY}/" /host/fluent-package/apt/systemd-test/opensearch.conf > /tmp/opensearch.conf
sudo cp /tmp/opensearch.conf /etc/fluent/fluentd.conf
cat /etc/fluent/fluentd.conf

curl --silent --insecure --user admin:Passvv0rd@ "https://${GATEWAY}:9200/_cat/indices?v"

sudo systemctl start fluentd
systemctl status --no-pager fluentd

# wait loading sample data
until curl --silent --insecure --user admin:Passvv0rd@ "https://${GATEWAY}:9200/_cat/indices?v" | grep -c 'fluentd-test'; do
    sleep 10
done

count=$(curl --silent --insecure --user admin:Passvv0rd@ "https://${GATEWAY}:9200/_search?q=message:hello&pretty" | jq ".hits.hits | length")
test $count -gt 0
