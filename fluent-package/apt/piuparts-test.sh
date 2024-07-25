#!/bin/bash

set -exu

if [ "$CI" = "true" ]; then
   echo "::group::Setup piuparts test"
fi

apt update
apt install -V -y lsb-release

. $(dirname $0)/commonvar.sh

if [ -z "$(apt-cache show piuparts 2>/dev/null)" ]; then
	# No piuparts package for noble and oracular. See https://packages.ubuntu.com/search?suite=noble&searchon=names&keywords=piuparts
	echo "As ${code_name} does not support piuparts, so piuparts test for ${code_name} is disabled"
	exit 0
fi

find ${repositories_dir}
DEBIAN_FRONTEND=noninteractive apt install -V -y piuparts mount gnupg curl eatmydata
gpg_command=gpg
curl https://packages.treasuredata.com/GPG-KEY-td-agent > td-agent.gpg
TD_AGENT_KEYRING=/usr/share/keyrings/td-agent-archive-keyring.gpg
${gpg_command} --no-default-keyring --keyring $TD_AGENT_KEYRING --import td-agent.gpg
CHROOT=/var/lib/chroot/${code_name}-root
mkdir -p $CHROOT
debootstrap --include=ca-certificates ${code_name} $CHROOT ${mirror}
cp $TD_AGENT_KEYRING $CHROOT/usr/share/keyrings/
chmod 644 $CHROOT/usr/share/keyrings/td-agent-archive-keyring.gpg
chroot $CHROOT apt install -V -y libyaml-0-2
package=${repositories_dir}/${distribution}/pool/${code_name}/${channel}/*/*/*_${architecture}.deb
cp ${package} /tmp
echo "deb [signed-by=/usr/share/keyrings/td-agent-archive-keyring.gpg] https://packages.treasuredata.com/5/${distribution}/${code_name}/ ${code_name} contrib" | tee $CHROOT/etc/apt/sources.list.d/td.list
rm -rf $CHROOT/opt
if [ "$CI" = "true" ]; then
   echo "::endgroup::"
fi
piuparts --distribution=${code_name} \
	 --existing-chroot=${CHROOT} \
	 --skip-logrotatefiles-test \
	 /tmp/*_${architecture}.deb
