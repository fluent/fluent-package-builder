#!/bin/bash

set -exu

. $(dirname $0)/commonvar.sh

# Install the current
package="/host/${distribution}/${DISTRIBUTION_VERSION}/x86_64/Packages/fluent-package-[0-9]*.rpm"
sudo $DNF install -y $package
sudo systemctl enable --now fluentd
systemctl status --no-pager fluentd

# Make a dummy pacakge for the next version
case $distribution in
    amazon)
        case $version in
	    2023)
		curl -L -o rpmrebuild.noarch.rpm https://sourceforge.net/projects/rpmrebuild/files/latest/download
		sudo $DNF install -y ./rpmrebuild.noarch.rpm
		;;
	    2)
		sudo amazon-linux-extras install -y epel
		sudo $DNF install -y rpmrebuild
	;;
	esac
        ;;
    *)
        sudo $DNF install -y epel-release
	sudo $DNF install -y rpmrebuild
        ;;
esac
# Example: "1.el9"
release=$(rpmquery --queryformat="%{Release}" -p $package)
# Example: "1"
release_ver=$(echo $release | cut -d . -f1)
# Example: "2.el9"
next_release=$(($release_ver+1)).$(echo $release | cut -d. -f2)
rpmrebuild --release=$next_release --modify="find $HOME -name fluentd.service | xargs sed -i -E 's/FLUENT_PACKAGE_VERSION=([0-9.]+)/FLUENT_PACKAGE_VERSION=\1.1/g'" --package $package
next_package=$(find rpmbuild -name "*.rpm")
rpm2cpio $next_package | cpio -id ./usr/lib/systemd/system/fluentd.service
next_package_ver=$(cat ./usr/lib/systemd/system/fluentd.service | grep "FLUENT_PACKAGE_VERSION" | sed -E "s/Environment=FLUENT_PACKAGE_VERSION=(.+)/\1/")
echo "repacked next fluent-package version: $next_package_ver"

# Install the dummy package of the next version
sudo $DNF install -y ./$next_package
# Test: take over enabled state
systemctl is-enabled fluentd
systemctl status --no-pager fluentd

# Test: migration process from v4 must not be done
(! test -e /etc/td-agent)
(! test -e /etc/fluent/td-agent.conf)
(! test -e /var/log/td-agent)
(! test -e /var/log/fluent/td-agent.log)
(! test -h /usr/sbin/td-agent)
(! test -h /usr/sbin/td-agent-gem)

# Test: environmental variables
pid=$(eval $(systemctl show fluentd --property=MainPID) && echo $MainPID)
env_vars=$(sudo sed -e 's/\x0/\n/g' /proc/$pid/environ)
test $(eval $env_vars && echo $HOME) = "/var/lib/fluent"
test $(eval $env_vars && echo $LOGNAME) = "fluentd"
test $(eval $env_vars && echo $USER) = "fluentd"
test $(eval $env_vars && echo $FLUENT_CONF) = "/etc/fluent/fluentd.conf"
test $(eval $env_vars && echo $FLUENT_PACKAGE_LOG_FILE) = "/var/log/fluent/fluentd.log"
test $(eval $env_vars && echo $FLUENT_PLUGIN) = "/etc/fluent/plugin"
test $(eval $env_vars && echo $FLUENT_SOCKET) = "/var/run/fluent/fluentd.sock"
# FLUENT_PACKAGE_VERSION will be updated after the next restart
(! test $(eval $env_vars && echo $FLUENT_PACKAGE_VERSION) = "$next_package_ver")

# Test: logs
sleep 3
test -e /var/log/fluent/fluentd.log
(! grep -e '\[warn\]' -e '\[error\]' -e '\[fatal\]' /var/log/fluent/fluentd.log)

# Test: fluent-diagtool
sudo fluent-gem install fluent-plugin-concat
sudo /opt/fluent/bin/fluent-diagtool -t fluentd -o /tmp
test $(find /tmp/ -name gem_local_list.output | xargs cat) = "fluent-plugin-concat"

# Test: Guard duplicated instance
(! sudo /usr/sbin/fluentd)
(! sudo /usr/sbin/td-agent)
(! sudo /usr/sbin/fluentd -v)
sudo /usr/sbin/fluentd --dry-run

# Uninstall
sudo $DNF remove -y fluent-package
sudo systemctl daemon-reload

(! getent passwd td-agent >/dev/null)
(! getent group td-agent >/dev/null)
getent passwd fluentd >/dev/null
getent group fluentd >/dev/null

# `sudo systemctl daemon-reload` clears the service completely.
#   (The result of `systemctl status` will be `unfound`)
# Note: RPM does not leave links like `@/etc/systemd/system/fluentd.service`.
#   (Different from deb)

(! systemctl status --no-pager fluentd)
