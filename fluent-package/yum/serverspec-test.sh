#!/bin/bash

set -exu

# Amazon Linux 2 system-release-cpe is:
# cpe:2.3:o:amazon:amazon_linux:2
# CentOS 7 system-release-cpe is:
# cpe:/o:centos:centos:7
# CentOS 6 system-release-cpe is:
# cpe:/o:centos:linux:6
# This means that column glitch exists.
# So, we should remove before "o" character.

if [ "$CI" = "true" ]; then
   echo "::group::Setup serverspec test"
fi

distribution=$(cat /etc/system-release-cpe | awk '{print substr($0, index($1, "o"))}' | cut -d: -f2)
version=$(cat /etc/system-release-cpe | awk '{print substr($0, index($1, "o"))}' | cut -d: -f4)

ENABLE_SERVERSPEC_TEST=1
ENABLE_KAFKA_TEST=1
JAVA_JRE=java-21-openjdk-headless
N_POLLING=30
case ${distribution} in
  amazon)
    case ${version} in
      2)
        DNF=yum
        DISTRIBUTION_VERSION=${version}
        JAVA_JRE=java-17-amazon-corretto-headless
        ;;
      2023)
        DNF=dnf
        DISTRIBUTION_VERSION=${version}
        JAVA_JRE=java-21-amazon-corretto-headless
        ;;
    esac
    ;;
  centos)
    case ${version} in
      7)
        DNF=yum
        DISTRIBUTION_VERSION=${version}
        ;;
      *)
        DNF="dnf --enablerepo=powertools"
        if [ x"${CENTOS_STREAM}" == x"true" ]; then
            echo "MIGRATE TO CENTOS STREAM"
            ${DNF} install centos-release-stream -y && \
                ${DNF} swap centos-{linux,stream}-repos -y && \
                ${DNF} distro-sync -y
            DISTRIBUTION_VERSION=${version}-stream
        else
            DISTRIBUTION_VERSION=${version}
        fi
        ;;
    esac
    ;;
  rocky|almalinux)
    DNF=dnf
    DISTRIBUTION_VERSION=$(echo ${version} | cut -d. -f1)
    version=$DISTRIBUTION_VERSION
    case ${version} in
      9)
        # FIXME: Accept SHA-1 signed confluent packages.
        update-crypto-policies --set LEGACY
        ;;
    esac
    ;;
esac

echo "INSTALL TEST"
repositories_dir=/fluentd/fluent-package/yum/repositories
${DNF} install -y \
  ${repositories_dir}/${distribution}/${DISTRIBUTION_VERSION}/x86_64/Packages/*.rpm

fluentd --version

if [ $ENABLE_SERVERSPEC_TEST -eq 1 ]; then
    curl -V > /dev/null 2>&1 || ${DNF} install -y curl
    ${DNF} install -y which ${repositories_dir}/${distribution}/${DISTRIBUTION_VERSION}/x86_64/Packages/*.rpm

    /usr/sbin/fluent-gem install --no-document serverspec
    if [ $ENABLE_KAFKA_TEST -eq 1 ]; then
        rpm --import https://packages.confluent.io/rpm/7.4/archive.key
        cat >/etc/yum.repos.d/confluent.repo <<EOF;
[Confluent]
name=Confluent repository
baseurl=https://packages.confluent.io/rpm/7.6
gpgcheck=1
gpgkey=https://packages.confluent.io/rpm/7.6/archive.key
enabled=1
EOF
	yum update -y && yum install -y confluent-community-2.13 ${JAVA_JRE} nc
	export KAFKA_OPTS=-Dzookeeper.4lw.commands.whitelist=ruok
	/usr/bin/zookeeper-server-start /etc/kafka/zookeeper.properties  &
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
	# Allow connection to kafka server
        echo "listeners=PLAINTEXT://localhost:9092" | tee -a /etc/kafka/server.properties
	/usr/bin/kafka-server-start /etc/kafka/server.properties &
	n=1
	while true ; do
	    sleep 1
	    status=$(/usr/bin/kafka-topics --bootstrap-server localhost:9092 --list)
	    if [ "$status" = "" ]; then
		break
	    fi
            n=$((n + 1))
	    if [ $n -ge $N_POLLING ]; then
		echo "failed to get list of topics from kafka-server"
		exit 1
	    fi
	done
	/usr/bin/kafka-topics --bootstrap-server localhost:9092 --topic test --create --replication-factor 1 --partitions 1
	/usr/sbin/fluentd -c /fluentd/serverspec/test.conf &
    fi
    if [ "$CI" = "true" ]; then
	echo "::endgroup::"
    fi
    export PATH=/opt/fluent/bin:$PATH
    export INSTALLATION_TEST=true
    cd /fluentd && rake serverspec:linux
fi
