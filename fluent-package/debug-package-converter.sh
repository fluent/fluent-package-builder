#!/usr/bin/bash

#
# Helper script to generate package which
# can enable debug verbose message in maintainer scripts.
# It helps to trace internal behavior install/upgrade/remove
# and so on.
#
# Usage: debug-package-converter.sh PATH_TO_DEB_OR_RPM
#
# e.g.
# $ debug-package-converter.sh fluent-package-6.0.0-1.el8.x86_64.rpm
# $ debug-package-converter.sh fluent-package_6.0.0-1_amd64.deb
#
# It repack to fluent-package-6.0.0-2.el8.x86_64.rpm or
# fluent-package_6.0.0-2_amd64.deb.
#

set -e

CLEANUP=1
PACKAGE=""
if [ -f "$1" ]; then
    PACKAGE=$1
fi
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
        cat >/tmp/repack.sh<<'EOF';
if find $HOME/.tmp -name fluentd.service ; then
    find $HOME/.tmp -name fluentd.service | xargs sed -i -E 's/^Environment=FLUENT_PACKAGE_VERSION=([0-9.]+)$/Environment=FLUENT_PACKAGE_VERSION=\1.1/g'
    find $HOME/.tmp -name fluentd.service | xargs cat
fi
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
        chmod +x /tmp/repack.sh
        rpmrebuild --release=$next_release --modify="/tmp/repack.sh ${version}-${next_release_ver}" --package $PACKAGE
        rm -f /tmp/repack.sh
        ;;
    *debian*|*ubuntu*)
        rm -fr tmp
        dpkg-deb -R $PACKAGE tmp
        package=$(cat tmp/DEBIAN/control | grep "Package: " | sed -E "s/Package: (.+)/\1/")
        architecture=$(cat tmp/DEBIAN/control | grep "Architecture: " | sed -E "s/Architecture: (.+)/\1/")
        version=$(cat tmp/DEBIAN/control | grep "Version: " | sed -E "s/Version: ([0-9.]+)-([0-9]+)/\1/")
        debian_version=$(cat tmp/DEBIAN/control | grep "Version: " | sed -E "s/Version: ([0-9.]+)-([0-9]+)/\2/")
        sed -i -E "s/Version: ([0-9.]+)-([0-9]+)/Version: \1-$(($debian_version+1))/g" tmp/DEBIAN/control
        # Bump up x.y.w.z to distinguish newer package
        if [ -f tmp/lib/systemd/system/fluentd.service ]; then
            sed -i -E "s/FLUENT_PACKAGE_VERSION=([0-9.]+)/FLUENT_PACKAGE_VERSION=\1.1/g" tmp/lib/systemd/system/fluentd.service
        fi
        next_release="$version-"$(($debian_version+1))
        for d in prerm postrm preinst postinst; do
            if [ -f tmp/DEBIAN/$d ]; then
                sed -i -e "s/^set -e/set -ex\necho \"#=> $d $next_release: \$1 (\$2)\"/" tmp/DEBIAN/$d
                echo "echo \"#<= $d $next_release: \$1 (\$2) END\"" >> tmp/DEBIAN/$d
            fi
        done
        dpkg-deb --build tmp ${package}_${next_release}_${architecture}.deb
        if [ $CLEANUP -eq 1 ]; then
            rm -rf tmp
        fi
        ;;
esac

