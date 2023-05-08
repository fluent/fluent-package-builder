#!/bin/bash

set -exu

apt update
apt install -V -y lsb-release

. $(dirname $0)/commonvar.sh

find ${repositories_dir}
DEBIAN_FRONTEND=noninteractive apt install -V -y piuparts mount gnupg curl eatmydata
gpg_command=gpg
curl https://packages.treasuredata.com/GPG-KEY-td-agent > td-agent.gpg
TD_AGENT_KEYRING=/usr/share/keyrings/td-agent-archive-keyring.gpg
${gpg_command} --no-default-keyring --keyring $TD_AGENT_KEYRING --import td-agent.gpg
CHROOT=/var/lib/chroot/${code_name}-root
mkdir -p $CHROOT
debootstrap ${code_name} $CHROOT ${mirror}
cp $TD_AGENT_KEYRING $CHROOT/usr/share/keyrings/
chmod 644 $CHROOT/usr/share/keyrings/td-agent-archive-keyring.gpg
chroot $CHROOT apt install -V -y libyaml-0-2
package=${repositories_dir}/${distribution}/pool/${code_name}/${channel}/*/*/*_${architecture}.deb
cp ${package} /tmp
echo "deb [signed-by=/usr/share/keyrings/td-agent-archive-keyring.gpg] https://packages.treasuredata.com/4/${distribution}/${code_name}/ ${code_name} contrib" | tee $CHROOT/etc/apt/sources.list.d/td.list
rm -rf $CHROOT/opt
piuparts --distribution=${code_name} \
	 --existing-chroot=${CHROOT} \
	 --mirror="http://packages.treasuredata.com/4/${distribution}/${code_name}/ ${code_name} contrib" \
	 --skip-logrotatefiles-test \
	 /tmp/*_${architecture}.deb
