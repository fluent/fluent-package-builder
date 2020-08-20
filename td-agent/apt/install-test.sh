#!/bin/bash

set -exu

apt update
apt install -V -y lsb-release

code_name=$(lsb_release --codename --short)
architecture=$(dpkg --print-architecture)
repositories_dir=/fluentd/td-agent/apt/repositories
java_jdk=openjdk-11-jre
case ${code_name} in
  xenial)
    distribution=ubuntu
    channel=universe
    mirror=http://archive.ubuntu.com/ubuntu/
    java_jdk=openjdk-8-jre
    ;;
  bionic|focal)
    distribution=ubuntu
    channel=universe
    mirror=http://archive.ubuntu.com/ubuntu/
    ;;
  buster)
    distribution=debian
    channel=main
    mirror=http://deb.debian.org/debian
    ;;
esac
apt install -V -y \
  ${repositories_dir}/${distribution}/pool/${code_name}/${channel}/*/*/*_${architecture}.deb

td-agent --version

find ${repositories_dir}
case ${code_name} in
    xenial)
	apt install -V -y piuparts mount gnupg curl eatmydata apt-transport-https
	gpg_command=gpg
	;;
    *)
	DEBIAN_FRONTEND=noninteractive apt install -V -y piuparts mount gnupg1 curl eatmydata
	gpg_command=gpg1
	;;
esac
curl https://packages.treasuredata.com/GPG-KEY-td-agent > td-agent.gpg
TD_AGENT_KEYRING=/usr/share/keyrings/td-agent-archive-keyring.gpg
${gpg_command} --no-default-keyring --keyring $TD_AGENT_KEYRING --import td-agent.gpg
CHROOT=/var/lib/chroot/${code_name}-root
mkdir -p $CHROOT
debootstrap ${code_name} $CHROOT ${mirror}
cp $TD_AGENT_KEYRING $CHROOT/etc/apt/trusted.gpg.d/
chmod 644 $CHROOT/etc/apt/trusted.gpg.d/td-agent-archive-keyring.gpg
chroot $CHROOT apt install -V -y libyaml-0-2
if [ "${code_name}" = "bionic" ]; then
   echo "deb http://archive.ubuntu.com/ubuntu bionic-updates main" > $CHROOT/etc/apt/sources.list
   chroot $CHROOT apt update
   chroot $CHROOT apt install -V -y libssl1.1
fi
package=${repositories_dir}/${distribution}/pool/${code_name}/${channel}/*/*/*_${architecture}.deb
cp ${package} /tmp
rm -rf $CHROOT/opt
piuparts --distribution=${code_name} \
	 --existing-chroot=${CHROOT} \
	 --keyring=$TD_AGENT_KEYRING \
	 --mirror="http://packages.treasuredata.com/4/${distribution}/${code_name}/ ${code_name} contrib" \
	 --skip-logrotatefiles-test \
	 /tmp/*_${architecture}.deb

/usr/sbin/td-agent-gem install serverspec
wget -qO - https://packages.confluent.io/deb/5.5/archive.key | apt-key add -
echo "deb [arch=${architecture}] https://packages.confluent.io/deb/5.5 stable main" > /etc/apt/sources.list.d/confluent.list
apt update && apt install -y confluent-community-2.12 ${java_jdk} nc

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
rake serverspec:linux
