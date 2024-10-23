#!/usr/bin/bash

#
# Helper script to generate package which
# can enable debug verbose message in maintainer scripts.
# It helps to trace internal behavior install/upgrade/remove
# and so on.
#
# Usage: debug-package-converter.sh [debug] PATH_TO_DEB_OR_RPM
#
# e.g.
# $ debug-package-converter.sh debug fluent-package-6.0.0-1.el8.x86_64.rpm
# $ debug-package-converter.sh debug fluent-package_6.0.0-1_amd64.deb
#
# It repack to fluent-package-6.0.0-2.el8.x86_64.rpm or
# fluent-package_6.0.0-2_amd64.deb.
#

DEBUG=0
CLEANUP=1
PACKAGE=""
echo $#
while [ $# -ne 0 ]; do
    case $1 in
	debug)
	    DEBUG=1
	    ;;
	*)
	    if [ -f $1 ]; then
		PACKAGE=$1
	    fi
	    ;;
    esac
    shift
done

if [ -z "$PACKAGE" ]; then
    echo "No package"
    exit 1
fi

PLATFORM_ID=$(cat /etc/os-release | grep '^ID=')
case $PLATFORM_ID in
    *rocky*|*almalinux*)
	# rpmrebuild extract to $HOME/.tmp/rpmrebuild.NNN/work:
	#
	# /home/vagrant/.tmp/rpmrebuild.13056/work
	# /home/vagrant/.tmp/rpmrebuild.13056/work/PROCESSING
	# /home/vagrant/.tmp/rpmrebuild.13056/work/rpmrebuild_rpmqf.src.1
	# /home/vagrant/.tmp/rpmrebuild.13056/work/rpmrebuild_rpmqf.src.2
	# /home/vagrant/.tmp/rpmrebuild.13056/work/rpmrebuild_rpmqf.src.3
	# /home/vagrant/.tmp/rpmrebuild.13056/work/rpmrebuild_rpmqf.src.4
	# /home/vagrant/.tmp/rpmrebuild.13056/work/rpmrebuild_rpmqf.src.5
	# /home/vagrant/.tmp/rpmrebuild.13056/work/rpmrebuild_rpmqf.src.6
	# /home/vagrant/.tmp/rpmrebuild.13056/work/rpmrebuild_rpmqf.src.7
	# /home/vagrant/.tmp/rpmrebuild.13056/work/preamble.1
	# /home/vagrant/.tmp/rpmrebuild.13056/work/conflicts.1
	# /home/vagrant/.tmp/rpmrebuild.13056/work/obsoletes.1
	# /home/vagrant/.tmp/rpmrebuild.13056/work/provides.1
	# /home/vagrant/.tmp/rpmrebuild.13056/work/requires.1
	# /home/vagrant/.tmp/rpmrebuild.13056/work/suggests.1
	# /home/vagrant/.tmp/rpmrebuild.13056/work/enhances.1
	# /home/vagrant/.tmp/rpmrebuild.13056/work/recommends.1
	# /home/vagrant/.tmp/rpmrebuild.13056/work/supplements.1
	# /home/vagrant/.tmp/rpmrebuild.13056/work/description.1
	# /home/vagrant/.tmp/rpmrebuild.13056/work/files.1
	# /home/vagrant/.tmp/rpmrebuild.13056/work/files.in
	# /home/vagrant/.tmp/rpmrebuild.13056/work/triggers.1
	# /home/vagrant/.tmp/rpmrebuild.13056/work/pre.1
	# /home/vagrant/.tmp/rpmrebuild.13056/work/pretrans.1
	# /home/vagrant/.tmp/rpmrebuild.13056/work/post.1
	# /home/vagrant/.tmp/rpmrebuild.13056/work/posttrans.1
	# /home/vagrant/.tmp/rpmrebuild.13056/work/preun.1
	# /home/vagrant/.tmp/rpmrebuild.13056/work/postun.1
	# /home/vagrant/.tmp/rpmrebuild.13056/work/verifyscript.1
	# /home/vagrant/.tmp/rpmrebuild.13056/work/changelog.1
	# /home/vagrant/.tmp/rpmrebuild.13056/work/root
	# Example: "1.el9"
	release=$(rpmquery --queryformat="%{Release}" -p $PACKAGE)
	version=$(rpmquery --queryformat="%{Version}" -p $PACKAGE)
	# Example: "1"
	release_ver=$(echo $release | cut -d . -f1)
	next_release_ver=$(($release_ver+1))
	# Example: "2.el9"
	next_release=$next_release_ver.$(echo $release | cut -d. -f2)
	if [ $DEBUG -eq 1 ]; then
	    cat >/tmp/repack.sh<<'EOF';
find $HOME/.tmp -name fluentd.service | xargs sed -i -E 's/^Environment=FLUENT_PACKAGE_VERSION=([0-9.]+)$/Environment=FLUENT_PACKAGE_VERSION=\1.1/g'
find $HOME/.tmp -name fluentd.service | xargs cat
find $HOME/.tmp -name pre.1 | xargs sed -i -e 's,%pre -p /bin/sh,%pre -p /bin/sh\necho "%%pre: ('$1'): $1"\nset -x,'
find $HOME/.tmp -name pre.1 | xargs sed -i -e '$s|$|\necho "%%pre '$1': $1 END"|g'
find $HOME/.tmp -name pre.1 | xargs cat
find $HOME/.tmp -name post.1 | xargs sed -i -e 's,%post -p /bin/sh,%post -p /bin/sh\necho "%%post ('$1'): $1"\nset -x,'
find $HOME/.tmp -name post.1 | xargs sed -i -e '$s|$|\necho "%%post '$1': $1 END"|g'
find $HOME/.tmp -name post.1 | xargs cat
find $HOME/.tmp -name preun.1 | xargs sed -i -e 's,%preun -p /bin/sh,%preun -p /bin/sh\necho "%%preun ('$1'): $1"\nset -x,'
find $HOME/.tmp -name preun.1 | xargs sed -i -e '$s|$|\necho "%%preun '$1': $1 END"|g'
find $HOME/.tmp -name preun.1 | xargs cat
find $HOME/.tmp -name postun.1 | xargs sed -i -e 's,%postun -p /bin/sh,%postun -p /bin/sh\necho "%%postun ('$1'): $1"\nset -x,'
find $HOME/.tmp -name postun.1 | xargs sed -i -e '$s|$|\necho "%%postun '$1': $1 END"|g'
find $HOME/.tmp -name postun.1 | xargs cat
EOF
	else
	    cat >/tmp/repack.sh<<'EOF';
find $HOME/.tmp -name fluentd.service | xargs sed -i -E 's/^Environment=FLUENT_PACKAGE_VERSION=([0-9.]+)$/Environment=FLUENT_PACKAGE_VERSION=\1.1/g'
EOF
	fi
	chmod +x /tmp/repack.sh
	rpmrebuild --release=$next_release --modify="/tmp/repack.sh ${version}-${next_release_ver}" --package $PACKAGE
	rm -f /tmp/repack.sh
	;;
    *debian*|*ubuntu*)
	rm -fr tmp
	dpkg-deb -R $PACKAGE tmp
	version=$(cat tmp/DEBIAN/control | grep "Version: " | sed -E "s/Version: ([0-9.]+)-([0-9]+)/\1/")
	debian_version=$(cat tmp/DEBIAN/control | grep "Version: " | sed -E "s/Version: ([0-9.]+)-([0-9]+)/\2/")
	sed -i -E "s/Version: ([0-9.]+)-([0-9]+)/Version: \1-$(($debian_version+1))/g" tmp/DEBIAN/control
	# Bump up x.y.w.z to distinguish newer package
	sed -i -E "s/FLUENT_PACKAGE_VERSION=([0-9.]+)/FLUENT_PACKAGE_VERSION=\1.1/g" tmp/lib/systemd/system/fluentd.service
	next_release="$version-"$(($debian_version+1))
	if [ $DEBUG -eq 1 ]; then
            sed -i -e "s/^set -e/set -ex\necho \"#=> prerm $next_release: \$1 (\$2)\"/" tmp/DEBIAN/prerm
            echo "echo \"#<= prerm $next_release: \$1 (\$2) END\"" >> tmp/DEBIAN/prerm
            sed -i -e "s/^set -e/set -ex\necho \"#=> postrm $next_release: \$1 (\$2)\"/" tmp/DEBIAN/postrm
            echo "echo \"#<= postrm $next_release: \$1 (\$2) END\"" >> tmp/DEBIAN/postrm
            sed -i -e "s/^set -e/set -ex\necho \"#=> preinst $next_release: \$1 (\$2)\"/" tmp/DEBIAN/preinst
            echo "echo \"#<= preinst $next_release: \$1 (\$2) END\"" >> tmp/DEBIAN/preinst
            sed -i -e "s/^set -e/set -ex\necho \"#=> postinst $next_release: \$1 (\$2)\"/" tmp/DEBIAN/postinst
            echo "echo \"#<= postinst $next_release: \$1 (\$2) END\"" >> tmp/DEBIAN/postinst
	fi
	dpkg-deb --build tmp fluent-package_${next_release}_amd64.deb
	if [ $CLEANUP -eq 1 ]; then
	    rm -rf tmp
	fi
	;;
esac

