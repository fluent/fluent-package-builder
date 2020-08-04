#!/bin/bash

set -exu

apt update
apt install -V -y lsb-release

code_name=$(lsb_release --codename --short)
architecture=$(dpkg --print-architecture)
repositories_dir=/fluentd/td-agent/apt/repositories
case ${code_name} in
  xenial|bionic|focal)
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
	apt install -V -y piuparts mount gnupg curl eatmydata
	gpg_command=gpg
	;;
    *)
	apt install -V -y piuparts mount gnupg1 curl eatmydata
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
package=${repositories_dir}/${distribution}/pool/${code_name}/${channel}/*/*/*_${architecture}.deb
cp ${package} /tmp
piuparts --distribution=${code_name} \
	 --existing-chroot=${CHROOT} \
	 --keyring=$TD_AGENT_KEYRING \
	 --mirror="http://packages.treasuredata.com/4/${distribution}/${code_name}/ ${code_name} contrib" \
	 --skip-logrotatefiles-test \
	 /tmp/*_${architecture}.deb
