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

CONFLUENT_SCRIPT=$(dirname $(realpath $0))/../run-confluent.sh
echo ${CONFLUENT_SCRIPT}
bash ${CONFLUENT_SCRIPT}

if [ "$CI" = "true" ]; then
   echo "::endgroup::"
fi

export PATH=/opt/fluent/bin:$PATH
export INSTALLATION_TEST=true
/usr/sbin/fluentd -c /fluentd/serverspec/test.conf &
cd /fluentd && rake serverspec:kafka
