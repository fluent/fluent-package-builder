# td-agent-builder

## About td-agent-builder

td-agent-builder is a new build system for [td-agent](http://docs.treasuredata.com/articles/td-agent) which aims to replace the traditional build system [omnibus-td-agent](https://github.com/treasure-data/omnibus-td-agent) since it has several problems due to [Omnibus](https://github.com/chef/omnibus)'s limitations.

### Changes from Treasure Agent 3

* Use system libraries: e.g. openssl
* Remove libraries for 3rd party gems: e.g. postgresql
* Remove `embedded` directory by omnibus
  * Use `/opt/td-agent/bin/fluent-cat` instead of `/opt/td-agent/embedded/bin/fluent-cat`
* Update core components: ruby, jemalloc and more

See also [this issue](https://github.com/treasure-data/omnibus-td-agent/issues/219) for omnibus problems.

## Prerequisites

### For building .rpm & .deb packages

  * Any host OS that is supported by Docker
    * Debian buster or Ubuntu 18.04 are recommended
  * [Docker](https://docs.docker.com/install/)
  * Ruby 2.4 or later
  * Git

### For building Windows package (.msi)

  * Windows OS (10 Pro or 2019 are verified)
  * [Docker Desktop for Windows](https://hub.docker.com/editions/community/docker-ce-desktop-windows)
    * You need to switch to "Windows containers" before using it.
  * [RubyInstaller](https://rubyinstaller.org/) 2.4 or later.
  * [Git for Windows](https://gitforwindows.org/)

After installed above software, you need to enable additional features from powershell (as admin).

```
dism.exe /online /enable-feature /featurename:Microsoft-Hyper-V /all /norestart
dism.exe /online /enable-feature /featurename:Containers /all/ norestart
```

Then restart Windows.

## How to build .rpm package

```console
% rake yum:build
```

By default, yum repositories for following platforms will be built under td-agent/yum/repositories/ directory:

  * CentOS 6 (x86_64)
  * CentOS 7 (x86_64)
  * CentOS 8 (x86_64)

You can choose target platforms by `YUM_TARGETS` environment variable like this:

```console
% rake yum:build YUM_TARGETS="centos-6,centos-7,centos-8"
```

You can find other supported platforms under td-agent/yum directory.

### Note for AArch64 platforms

You can also build packages for AArch64 platforms like this:

```console
% rake yum:build YUM_TARGETS="centos-8-aarch64"
```

But if you use older GNU/Linux platforms (e.g. Ubuntu 18.04 or before) as your host OS, you need to copy qemnu-aarch64-static into the base directory of the target:

```console
% export TARGET_BASE="centos-8"
% sudo apt install qemu-user-static
% cd /path/to/td-agent-builder
% cp /usr/bin/qemu-aarch64-static td-agent/yum/${TARGET_BASE}
% rake yum:build YUM_TARGETS="${TARGET_BASE}-aarch64"
```

## How to build .deb package

```console
% rake apt:build
```

By default, apt repositories for following platforms will be built under td-agent/apt/repositories/ directory:

  * Debian 10 "Buster" (x86_64)
  * Ubuntu 18.04 LTS "Bionic Beaver" (x86_64)

You can choose target platforms by `APT_TARGETS` environment variable like this:

```console
% rake apt:build APT_TARGETS="debian-buster,ubuntu-bionic"
```

You can find other supported platforms under td-agent/apt directory.

### Note for AArch64 platforms

You can also built packages for AArch64 platforms like this:

```console
% rake apt:build APT_TARGETS="ubuntu-bionic-arm64"
```

But if you use older GNU/Linux platforms (e.g. Ubuntu 18.04 or before) as your host OS, you need to copy qemnu-aarch64-static into the base directory of the target:

```console
% export TARGET_BASE="ubuntu-bionic"
% sudo apt install qemu-user-static
% cd /path/to/td-agent-builder
% cp /usr/bin/qemu-aarch64-static td-agent/apt/${TARGET_BASE}
% rake apt:build APT_TARGETS="${TARGET_BASE}-arm64"
```

## How to build .msi package

```console
% rake msi:build
```

A td-agent-${version}-x64.msi package will be built under td-agent/msi directory.

## How to bump up the package version

* Edit td-agent/config.rb to choose Ruby & Fluentd versions
* Edit td-agent/core_gems.rb & td-agent/plugin_gems.rb to choose bundled gems
* Bump up the versions of rpm & deb packages by the following command:
```
% cd td-agent
% rake version:update
% git diff  # Check the change log
% git commit -a
```
* Build packages
```
% rake deb:build
% rake yum:build
% rake msi:build
```
