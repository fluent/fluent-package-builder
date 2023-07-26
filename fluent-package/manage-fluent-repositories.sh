#!/bin/bash

# Utility to manage rpm/deb repositories for packages.treasuredata.com
#
# Usage:
#   $ manage-fluent-repositories.sh COMMAND FLUENT_RELEASE_DIR
#
# NOTE: setup AccessKeyId, SecretAccessKey, SessionToken and AWS release-td-agent profile in beforehand
#   $ aws sts get-session-token --serial-number arn:aws:iam::523683666290:mfa/clearcode-xxx --profile USER_PROFILE --duration-seconds 129600 --token-code XXXXX
#

set -e

function usage {
    cat <<EOF
Usage:
  $0 COMMAND [FLUENT_RELEASE_PROFILE] [FLUENT_RELEASE_DIR] [FLUENT_PACKAGE_VERSION]

Example:
  $ $0 ls release-td-agent
  $ $0 dry-download release-td-agent /tmp/td-agent-release
  $ $0 download release-td-agent /tmp/td-agent-release
  $ $0 dry-upload release-td-agent /tmp/td-agent-release
  $ $0 upload release-td-agent /tmp/td-agent-release
  $ $0 deb /tmp/td-agent-release 4.2.0
  $ $0 rpm /tmp/td-agent-release 4.2.0
EOF
}

if [ $# -eq 0 ]; then
    usage
    exit 1
fi

COMMAND=$1
SIGNING_KEY=BEE682289B2217F45AF4CC3F901F9177AB97ACBE

case $COMMAND in
    deb|rpm)
	FLUENT_RELEASE_DIR=$2
	FLUENT_PACKAGE_VERSION=$3
	if [ -z "$FLUENT_PACKAGE_VERSION" ]; then
	    echo "ERROR: No package version for releasing fluentd packages, (e.g export FLUENT_PACKAGE_VERSION=4.2.0)"
	    exit 1
	fi
	;;
    *)
	FLUENT_RELEASE_PROFILE=$2
	FLUENT_RELEASE_DIR=$3
	FLUENT_PACKAGE_VERSION=$4
	if [ -z "$FLUENT_RELEASE_PROFILE" ]; then
	    echo "ERROR: No s3 profile for releasing fluentd packages"
	    usage
	    exit 1
	fi
	;;
esac

case $COMMAND in
    ls)
	# check whether profile and permission is valid
	command="aws s3 ls s3://packages.treasuredata.com --profile $FLUENT_RELEASE_PROFILE"
	echo $command
	$command
	;;
    dry-upload|upload)
	TARGETS="amazon redhat windows macosx debian/bullseye debian/bookworm ubuntu/jammy ubuntu/focal"
	DRYRUN_OPTION="--dryrun"
	if [ $COMMAND = "upload" ]; then
	   DRYRUN_OPTION=""
	fi
	for target in $TARGETS; do
	    case $FLUENT_RELEASE_DIR in
		*lts)
		    command="aws s3 sync $DRYRUN_OPTION --delete $FLUENT_RELEASE_DIR/5/$target s3://packages.treasuredata.com/lts/5/$target --profile $FLUENT_RELEASE_PROFILE"
		    ;;
		*)
		    command="aws s3 sync $DRYRUN_OPTION --delete $FLUENT_RELEASE_DIR/5/$target s3://packages.treasuredata.com/5/$target --profile $FLUENT_RELEASE_PROFILE"
		    ;;
	    esac
	    echo $command
	    $command
	done
	;;
    dry-download|download)
	VERSIONS="5"
	DRYRUN_OPTION="--dryrun"
	if [ $COMMAND = "download" ]; then
	   DRYRUN_OPTION=""
	fi
	for target in $VERSIONS; do
	    case $FLUENT_RELEASE_DIR in
		*lts)
		    command="aws s3 sync $DRYRUN_OPTION --delete s3://packages.treasuredata.com/lts/$target $FLUENT_RELEASE_DIR/$target --profile $FLUENT_RELEASE_PROFILE"
		    ;;
		*)
		    command="aws s3 sync $DRYRUN_OPTION --delete s3://packages.treasuredata.com/$target $FLUENT_RELEASE_DIR/$target --profile $FLUENT_RELEASE_PROFILE"
		    ;;
	    esac
	    echo $command
	    $command
	done
	;;
    deb)
	# Use custom .aptly and .aptly.conf (Do not override ~/.aptly)
	aptly_rootdir=$(realpath $FLUENT_RELEASE_DIR/../.aptly)
	aptly_conf=$(realpath $FLUENT_RELEASE_DIR/../.aptly.conf)
	rm -fr "$aptly_rootdir"
	mkdir -p "$aptly_rootdir"
	cat << EOF > "$aptly_conf"
{
    "rootDir": "$aptly_rootdir",
    "architectures": ["all", "amd64", "arm64"]
}
EOF
	echo "Ready to type signing passphrase? (process starts in 10 seconds, Ctrl+C to abort)"
	sleep 10
	export GPG_TTY=$(tty)
	for d in bullseye bookworm focal jammy; do
	    aptly -config="$aptly_conf" repo create -distribution=$d -component=contrib fluent-package5-$d
	    case $d in
		bullseye|bookworm)
		    aptly -config="$aptly_conf" repo add fluent-package5-$d $FLUENT_RELEASE_DIR/5/debian/$d/
		    aptly -config="$aptly_conf" snapshot create fluent-package5-$d-${FLUENT_PACKAGE_VERSION}-1 from repo fluent-package5-$d
		    # publish snapshot with prefix, InRelease looks like (e.g. bullseye):
		    #   Origin: bullseye bullseye
		    #   Label: bullseye bullseye
		    aptly -config="$aptly_conf" publish snapshot -component=contrib -gpg-key=$SIGNING_KEY fluent-package5-$d-${FLUENT_PACKAGE_VERSION}-1 $d
		    # Place generated files, package files themselves are already in there
		    tar cf - --exclude="td-agent_*.deb" --exclude="fluent-package_*.deb" -C "$aptly_rootdir/public" $d | tar xvf - -C $FLUENT_RELEASE_DIR/5/debian/
		    ;;
		focal|jammy)
		    aptly -config="$aptly_conf" repo add fluent-package5-$d $FLUENT_RELEASE_DIR/5/ubuntu/$d/
		    aptly -config="$aptly_conf" snapshot create fluent-package5-$d-${FLUENT_PACKAGE_VERSION}-1 from repo fluent-package5-$d
		    # publish snapshot with prefix, InRelease looks like (e.g. focal):
		    #   Origin: focal focal
		    #   Label: focal focal
		    aptly -config="$aptly_conf" publish snapshot -component=contrib -gpg-key=$SIGNING_KEY fluent-package5-$d-${FLUENT_PACKAGE_VERSION}-1 $d
		    # Place generated files, package files themselves are already in there
		    tar cf - --exclude="td-agent_*.deb" --exclude="fluent-package_*.deb" -C "$aptly_rootdir/public" $d | tar xvf - -C $FLUENT_RELEASE_DIR/5/ubuntu/
		    ;;
	    esac
	done
	rm -rf "$aptly_rootdir" "$aptly_conf"
	;;
    rpm)
	# resign rpm packages
	find $FLUENT_RELEASE_DIR/5 -name "*$FLUENT_PACKAGE_VERSION*.rpm"
	echo "Ready to type signing passphrase? (process starts in 10 seconds, Ctrl+C to abort)"
	sleep 10
	export GPG_TTY=$(tty)
	find $FLUENT_RELEASE_DIR/5 -name "*$FLUENT_PACKAGE_VERSION*.rpm" | xargs rpm --resign --define "_gpg_name support@treasure-data.com"
	find $FLUENT_RELEASE_DIR/5 -name "*$FLUENT_PACKAGE_VERSION*.rpm" | xargs rpm -K

	# update & sign rpm repository
	repodirs=`find "${FLUENT_RELEASE_DIR}" -regex "^${FLUENT_RELEASE_DIR}/5/\(redhat\|amazon\)/\([2789]\|2023\)/\(x86_64\|aarch64\)$"`
	for repodir in $repodirs; do
	    createrepo_c -v "${repodir}"

	    repofile="${repodir}/repodata/repomd.xml"
	    if [ -f "${repofile}.asc" ]; then
		rm -f "${repofile}.asc"
	    fi
	    gpg --verbose --detach-sign --armor --local-user $SIGNING_KEY "${repofile}"
	done
	;;
    *)
	usage
	exit 1
	;;
esac
