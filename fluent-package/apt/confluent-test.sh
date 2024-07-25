#!/bin/bash

set -exu

if [ "$CI" = "true" ]; then
   echo "::group::Setup confluent test"
fi

export DEBIAN_FRONTEND=noninteractive

apt update
apt install -V -y lsb-release

. $(dirname $0)/commonvar.sh

apt install -V -y \
  ${repositories_dir}/${distribution}/pool/${code_name}/${channel}/*/*/*_${architecture}.deb

fluentd --version

case ${code_name} in
    xenial)
	apt install -V -y gnupg2 wget apt-transport-https
	;;
    *)
	apt install -V -y gnupg2 wget
	;;
esac

/usr/sbin/fluent-gem install --no-document serverspec
wget https://packages.confluent.io/deb/7.6/archive.key
gpg2 --homedir /tmp --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/confluent-archive-keyring.gpg --import archive.key
chmod 644 /usr/share/keyrings/confluent-archive-keyring.gpg
echo "deb [arch=${architecture} signed-by=/usr/share/keyrings/confluent-archive-keyring.gpg] https://packages.confluent.io/deb/7.6 stable main" > /etc/apt/sources.list.d/confluent.list
apt update && apt install -y confluent-community-2.13 ${java_jdk} netcat-openbsd

export KAFKA_OPTS=-Dzookeeper.4lw.commands.whitelist=ruok
/usr/bin/zookeeper-server-start /etc/kafka/zookeeper.properties  &
N_POLLING=30
n=1
while true ; do
    sleep 1
    status=$(echo ruok | nc localhost 2181)
    if [ "$status" = "imok" ]; then
	break
    fi
    n=$((n + 1))
    if [ $n -ge $N_POLLING ]; then
	echo "failed to get response from zookeeper-server"
	exit 1
    fi
done
/usr/bin/kafka-server-start /etc/kafka/server.properties &
n=1
while true ; do
    sleep 1
    status=$(/usr/bin/zookeeper-shell localhost:2181 ls /brokers/ids | sed -n 6p)
    if [ "$status" = "[0]" ]; then
	break
    fi
    n=$((n + 1))
    if [ $n -ge $N_POLLING ]; then
	echo "failed to get response from kafka-server"
	exit 1
    fi
done
if [ "$CI" = "true" ]; then
   echo "::endgroup::"
fi
/usr/bin/kafka-topics --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic test
export PATH=/opt/fluent/bin:$PATH
export INSTALLATION_TEST=true
cd /fluentd && rake serverspec:kafka
/usr/sbin/fluentd -c /fluentd/serverspec/test.conf &
