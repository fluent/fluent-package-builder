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
  $ $0 download-artifacts pull/587
EOF
}

if [ $# -eq 0 ]; then
    usage
    exit 1
fi

COMMAND=$1
# Fluentd developers (Fluent Package Official Signing Key
SIGNING_KEY=B40948B6A3B80E90F40E841F977D7A0943FA320E

case $COMMAND in
    deb|rpm)
	FLUENT_RELEASE_DIR=$2
	FLUENT_PACKAGE_VERSION=$3
	if [ -z "$FLUENT_PACKAGE_VERSION" ]; then
	    echo "ERROR: No package version for releasing fluentd packages, (e.g export FLUENT_PACKAGE_VERSION=4.2.0)"
	    exit 1
	fi
	;;
    download-artifacts)
	# Given URL will not be used. Just use the number of pull request.
	# Allow copying the URL from browser's URL bar.
	PULL_REQUEST_URL=$2
	PULL_NUMBER=${PULL_REQUEST_URL##*/}
	read -rsp "Please enter your GitHub personal access token: " GITHUB_ACCESS_TOKEN
	echo
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
	TARGETS="amazon redhat windows macosx debian/bullseye debian/bookworm ubuntu/jammy ubuntu/focal ubuntu/noble"
	DRYRUN_OPTION="--dryrun"
	if [ $COMMAND = "upload" ]; then
	   DRYRUN_OPTION=""
	fi
	for target in $TARGETS; do
	    case $FLUENT_RELEASE_DIR in
		*test/experimental/lts)
		    command="aws s3 sync $DRYRUN_OPTION --delete $FLUENT_RELEASE_DIR/5/$target s3://packages.treasuredata.com/test/experimental/lts/5/$target --profile $FLUENT_RELEASE_PROFILE"
		    ;;
		*test/experimental)
		    command="aws s3 sync $DRYRUN_OPTION --delete $FLUENT_RELEASE_DIR/5/$target s3://packages.treasuredata.com/test/experimental/5/$target --profile $FLUENT_RELEASE_PROFILE"
		    ;;
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
		*test/experimental/lts)
		    command="aws s3 sync $DRYRUN_OPTION --delete s3://packages.treasuredata.com/test/experimental/lts/$target $FLUENT_RELEASE_DIR/$target --profile $FLUENT_RELEASE_PROFILE"
		    ;;
		*test/experimental)
		    command="aws s3 sync $DRYRUN_OPTION --delete s3://packages.treasuredata.com/test/experimental/$target $FLUENT_RELEASE_DIR/$target --profile $FLUENT_RELEASE_PROFILE"
		    ;;
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
	for d in bullseye bookworm focal jammy noble; do
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
		focal|jammy|noble)
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
	find $FLUENT_RELEASE_DIR/5 -name "*$FLUENT_PACKAGE_VERSION*.rpm" | xargs rpm --resign --define "_gpg_name $SIGNING_KEY"
	# check whether packages are signed correctly.
	find $FLUENT_RELEASE_DIR/5 -name "*$FLUENT_PACKAGE_VERSION*.rpm" | xargs rpm -K || \
	    (echo "Import public key to verify: rpm --import https://s3.amazonaws.com/packages.treasuredata.com/GPG-KEY-fluent-package" && exit 1)

	# update & sign rpm repository
	repodirs=`find "${FLUENT_RELEASE_DIR}" -regex "^${FLUENT_RELEASE_DIR}/5/\(redhat\|amazon\)/\([2789]\|2023\)/\(x86_64\|aarch64\)$"`
	for repodir in $repodirs; do
	    createrepo_c -v --compatibility "${repodir}"

	    repofile="${repodir}/repodata/repomd.xml"
	    if [ -f "${repofile}.asc" ]; then
		rm -f "${repofile}.asc"
	    fi
	    gpg --verbose --detach-sign --armor --local-user $SIGNING_KEY "${repofile}"
	done
	;;
    download-artifacts)
	response=$(curl --silent --location \
	     -H "Accept: application/vnd.github+json" \
	     -H "Authorization: Bearer $GITHUB_ACCESS_TOKEN" \
	     -H "X-GitHub-Api-Version: 2022-11-28" \
	     https://api.github.com/repos/fluent/fluent-package-builder/pulls/$PULL_NUMBER | jq --raw-output '.head | .ref + " " + .sha')
	head_branch=$(echo $response | cut -d' ' -f1)
	head_sha=$(echo $response | cut -d' ' -f2)
	rm -f dl.list
	curl --silent --location \
	     -H "Accept: application/vnd.github+json" \
	     -H "Authorization: Bearer $GITHUB_ACCESS_TOKEN" \
	     -H "X-GitHub-Api-Version: 2022-11-28" \
	     "https://api.github.com/repos/fluent/fluent-package-builder/actions/artifacts?per_page=100&page=$d" | \
	    jq --raw-output '.artifacts[] | select(.workflow_run.head_branch == "'$head_branch'" and .workflow_run.head_sha == "'$head_sha'") | .name + " " + (.size_in_bytes|tostring) + " " + .archive_download_url' > dl.list
	while read line
	do
	    package=$(echo $line | cut -d' ' -f1)
	    download_url=$(echo $line | cut -d' ' -f3)
	    echo "Downloading $package.zip from $download_url"
	    case $package in
		*debian*|*ubuntu*)
		    mkdir -p apt/repositories
		    (cd apt/repositories &&
			 rm -f $package.zip &&
			 curl --silent --location --output $package.zip \
			      -H "Authorization: Bearer $GITHUB_ACCESS_TOKEN" $download_url ) &
		    ;;
		*centos*|*rockylinux*|*almalinux*|*amazonlinux*)
		    mkdir -p yum/repositories
		    (cd yum/repositories &&
			 rm -f $package.zip &&
			 curl --silent --location --output $package.zip \
			      -H "Authorization: Bearer $GITHUB_ACCESS_TOKEN" $download_url ) &
		    ;;
		*)
		    curl --silent --location --output $package.zip \
			 -H "Authorization: Bearer $GITHUB_ACCESS_TOKEN" $download_url &
		    ;;
	    esac
	done < dl.list
	wait

	verified=1
	while read line
	do
	    package=$(echo $line | cut -d' ' -f1)
	    download_size=$(echo $line | cut -d' ' -f2)
	    case $package in
		*debian*|*ubuntu*)
		    actual_size=$(stat --format="%s" apt/repositories/$package.zip)
		    ;;
		*rockylinux*|*almalinux*|*amazonlinux*)
		    actual_size=$(stat --format="%s" yum/repositories/$package.zip)
		    ;;
		*)
		    actual_size=$(stat --format="%s" $package.zip)
		    ;;
	    esac
	    if [ $download_size = "$actual_size" ]; then
		echo -e "[\e[32m\e[40mOK\e[0m] Verify apt/repositories/$package.zip"
	    else
		echo -e "[\e[31m\e[40mNG\e[0m] Verify apt/repositories/$package.zip (expected: $download_size actual: $actual_size)"
		verified=0
	    fi
	done < dl.list
	if [ $verified -eq 0 ]; then
	    echo "Downloaded artifacts were corrupted! Check the downloaded artifacts."
	    exit 1
	fi
	(cd apt/repositories && find . -name '*.zip' -exec unzip -u -o {} \;)
	(cd yum/repositories && find . -name '*.zip' -exec unzip -u -o {} \;)
	;;
    *)
	usage
	exit 1
	;;
esac
