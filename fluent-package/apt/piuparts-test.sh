#!/bin/bash

set -exu

if [ "$CI" = "true" ]; then
   echo "::group::Setup piuparts test"
fi

apt update --quiet
apt install -V -y --quiet lsb-release

. $(dirname $0)/commonvar.sh

if [ -z "$(apt-cache show piuparts 2>/dev/null)" ]; then
	# No piuparts package for noble and oracular. See https://packages.ubuntu.com/search?suite=noble&searchon=names&keywords=piuparts
	echo "As ${code_name} does not support piuparts, so piuparts test for ${code_name} is disabled"
	exit 0
fi

case $code_name in
    trixie)
	echo "As ${code_name} is not published for v5, so piuparts check for ${code_name} is disabled"
	exit 0
	;;
esac

find ${repositories_dir}
DEBIAN_FRONTEND=noninteractive apt install -V -y piuparts mount gnupg curl eatmydata
gpg_command=gpg
curl https://packages.treasuredata.com/GPG-KEY-td-agent > td-agent.gpg
curl https://packages.treasuredata.com/GPG-KEY-fluent-package > fluent-package.gpg
FLUENT_PACKAGE_KEYRING=/usr/share/keyrings/fluent-package-archive-keyring.gpg
${gpg_command} --no-default-keyring --keyring $FLUENT_PACKAGE_KEYRING --import td-agent.gpg
${gpg_command} --no-default-keyring --keyring $FLUENT_PACKAGE_KEYRING --import fluent-package.gpg
CHROOT=/var/lib/chroot/${code_name}-root
mkdir -p $CHROOT
debootstrap --include=ca-certificates ${code_name} $CHROOT ${mirror}
cp $FLUENT_PACKAGE_KEYRING $CHROOT/usr/share/keyrings/
chmod 644 $CHROOT/usr/share/keyrings/fluent-package-archive-keyring.gpg
chroot $CHROOT apt install -V -y --quiet libyaml-0-2
package=${repositories_dir}/${distribution}/pool/${code_name}/${channel}/*/*/*_${architecture}.deb
cp ${package} /tmp
echo "deb [signed-by=/usr/share/keyrings/fluent-package-archive-keyring.gpg] https://packages.treasuredata.com/5/${distribution}/${code_name}/ ${code_name} contrib" | tee $CHROOT/etc/apt/sources.list.d/fluent-package.list
rm -rf $CHROOT/opt
if [ "$CI" = "true" ]; then
   echo "::endgroup::"
fi
piuparts --distribution=${code_name} \
	 --existing-chroot=${CHROOT} \
	 --skip-logrotatefiles-test \
	 /tmp/*_${architecture}.deb
