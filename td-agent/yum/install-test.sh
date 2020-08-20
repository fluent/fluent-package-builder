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

distribution=$(cat /etc/system-release-cpe | awk '{print substr($0, index($1, "o"))}' | cut -d: -f2)
version=$(cat /etc/system-release-cpe | awk '{print substr($0, index($1, "o"))}' | cut -d: -f4)

ENABLE_UPGRADE_TEST=1
ENABLE_SERVERSPEC_TEST=1
JAVA_JRE=java-11-openjdk
case ${distribution} in
  amazon)
    case ${version} in
      2)
        DNF=yum
        ENABLE_SERVERSPEC_TEST=0
        ;;
    esac
    ;;
  centos)
    case ${version} in
      6)
        DNF=yum
        JAVA_JRE=java-1.8.0-openjdk
        ;;
      7)
        DNF=yum
        ;;
      *)
        DNF="dnf --enablerepo=PowerTools"
        ENABLE_UPGRADE_TEST=0
        ;;
    esac
    ;;
esac

echo "INSTALL TEST"
repositories_dir=/fluentd/td-agent/yum/repositories
${DNF} install -y \
  ${repositories_dir}/${distribution}/${version}/x86_64/Packages/*.rpm

td-agent --version

echo "UNINSTALL TEST"
${DNF} remove -y td-agent

if [ $ENABLE_UPGRADE_TEST -eq 1 ]; then
    echo "UPGRADE TEST from v3"
    rpm --import https://packages.treasuredata.com/GPG-KEY-td-agent
    case ${distribution} in
        amazon)
            cat >/etc/yum.repos.d/td.repo <<'EOF';
[treasuredata]
name=TreasureData
baseurl=https://packages.treasuredata.com/3/amazon/2/\$releasever/\$basearch
gpgcheck=1
gpgkey=https://packages.treasuredata.com/GPG-KEY-td-agent
EOF

            ;;
        *)
            cat >/etc/yum.repos.d/td.repo <<'EOF';
[treasuredata]
name=TreasureData
baseurl=https://packages.treasuredata.com/3/redhat/\$releasever/\$basearch
gpgcheck=1
gpgkey=https://packages.treasuredata.com/GPG-KEY-td-agent
EOF
            ;;
    esac
    ${DNF} update -y
    ${DNF} install -y td-agent
    ${DNF} install -y \
           ${repositories_dir}/${distribution}/${version}/x86_64/Packages/*.rpm
fi

if [ $ENABLE_SERVERSPEC_TEST -eq 1 ]; then
    yum install -y curl which
    rpm --import https://packages.confluent.io/rpm/5.5/archive.key

    cat >/etc/yum.repos.d/confluent.repo <<EOF;
[Confluent.dist]
name=Confluent repository (dist)
baseurl=https://packages.confluent.io/rpm/5.5/${version}
gpgcheck=1
gpgkey=https://packages.confluent.io/rpm/5.5/archive.key
enabled=1

[Confluent]
name=Confluent repository
baseurl=https://packages.confluent.io/rpm/5.5
gpgcheck=1
gpgkey=https://packages.confluent.io/rpm/5.5/archive.key
enabled=1
EOF
    yum update && yum install -y confluent-community-2.12 ${JAVA_JRE} nc

    /usr/sbin/td-agent-gem install serverspec
    export KAFKA_OPTS=-Dzookeeper.4lw.commands.whitelist=ruok
    /usr/bin/zookeeper-server-start /etc/kafka/zookeeper.properties  &
    while true ; do
	sleep 1
	status=$(echo ruok | nc localhost 2181)
	if [ "$status" = "imok" ]; then
	    break
	fi
    done
    /usr/bin/kafka-server-start /etc/kafka/server.properties &
    while true ; do
	sleep 1
	status=$(/usr/bin/zookeeper-shell localhost:2181 ls /brokers/ids | sed -n 6p)
	if [ "$status" = "[0]" ]; then
	    break
	fi
    done
    /usr/bin/kafka-topics --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic test
    /usr/sbin/td-agent -c /fluentd/serverspec/test.conf &
    cd /fluentd/td-agent && /opt/td-agent/bin/rake serverspec:linux
fi
