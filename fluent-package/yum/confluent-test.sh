#!/bin/bash

set -exu

if [ "$CI" = "true" ]; then
   echo "::group::Setup confluent test"
fi

# Amazon Linux 2 system-release-cpe is:
# cpe:2.3:o:amazon:amazon_linux:2
# CentOS 7 system-release-cpe is:
# cpe:/o:centos:centos:7
# This means that column glitch exists.
# So, we should remove before "o" character.

distribution=$(cat /etc/system-release-cpe | awk '{print substr($0, index($1, "o"))}' | cut -d: -f2)
version=$(cat /etc/system-release-cpe | awk '{print substr($0, index($1, "o"))}' | cut -d: -f4)

case ${distribution} in
    amazon)
	case ${version} in
	    2)
		DNF=yum
		DISTRIBUTION_VERSION=${version}
		${DNF} install -y java-17-amazon-corretto-headless
		;;
	    2023)
		DNF=dnf
		DISTRIBUTION_VERSION=${version}
		${DNF} install -y java-21-amazon-corretto-headless
	    ;;
	esac
	;;
    rocky|almalinux)
	DNF=dnf
	DISTRIBUTION_VERSION=$(echo ${version} | cut -d. -f1)
	${DNF} install -y java-21-openjdk-headless
	;;
esac

repositories_dir=/fluentd/fluent-package/yum/repositories
ARCH=$(rpm --eval "%{_arch}")
${DNF} install -y \
  ${repositories_dir}/${distribution}/${DISTRIBUTION_VERSION}/${ARCH}/Packages/*.rpm

fluentd --version

/usr/sbin/fluent-gem install --no-document serverspec
rpm --import https://packages.confluent.io/rpm/7.6/archive.key

cat <<EOF > /etc/yum.repos.d/confluent.repo
[Confluent]
name=Confluent repository
baseurl=https://packages.confluent.io/rpm/7.6
gpgcheck=1
gpgkey=https://packages.confluent.io/rpm/7.6/archive.key
enabled=1
EOF
${DNF} update -y && ${DNF} install -y confluent-community-2.13 nmap-ncat

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
/usr/bin/kafka-topics --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic test

if [ "$CI" = "true" ]; then
   echo "::endgroup::"
fi

if [ "$CI" = "true" ]; then
   echo "::endgroup::"
fi

export PATH=/opt/fluent/bin:$PATH
export INSTALLATION_TEST=true
/usr/sbin/fluentd -c /fluentd/serverspec/test.conf &
cd /fluentd && rake serverspec:kafka
