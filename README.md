# td-agent-builder

## About td-agent-builder

td-agent-builder is a new build system for [td-agent](http://docs.treasuredata.com/articles/td-agent) which aims to replace the traditional build system [omnibus-td-agent](https://github.com/treasure-data/omnibus-td-agent) since it has several problems due to [Omnibus](https://github.com/chef/omnibus)'s limitations.

## Prerequisites

### For building .rpm & .deb packages

  * Any host OS that is supported by Docker
    * Debian buster or Ubuntu 18.04 are recommended
  * [Docker](https://docs.docker.com/install/)
  * Ruby 2.2 or later
  * Git

### For building Windows package (.msi)

  * Windows OS (10 or 2019 are verified)
  * [Docker Desktop for Windows](https://hub.docker.com/editions/community/docker-ce-desktop-windows)
    * You need to switch to "Windows containers" before using it.
  * [RubyInstaller](https://rubyinstaller.org/) 2.2 or later.
  * [Git for Windows](https://gitforwindows.org/)

## How to build .rpm package

```console
% rake yum:build
```

By default, yum repositories for following platforms will be built under td-agent/yum/repositories/ directory:

  * CentOS 7 (x86_64)
  * CentOS 8 (x86_64)

You can choose target platforms by `YUM_TARGETS` environment variable like this:

```console
% rake yum:build YUM_TARGETS="centos-7,centos-8"
```

You can find other supported platforms under td-agent/yum directory.

### Note for AArch64 platforms

You can also built packages for AArch64 platforms like this:

```console
% rake yum:build YUM_TARGETS="centos-8-aarch64"
```

But if you use older GNU/Linux platforms (e.g. Ubuntu 18.04 or before) as your host OS, you need to copy qemnu-aarch64-static into td-agent/yum/${TARGET}:

```console
% export TARGET="centos-8-aarch64"
% sudo apt install qemu-user-static
% cd /path/to/td-agent-builder
% cp /usr/bin/qemu-aarch64-static td-agent/yum/${TARGET}
% rake yum:build YUM_TARGETS=${TARGET}
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
% rake yum:build APT_TARGETS="debian-buster,ubuntu-bionic"
```

You can find other supported platforms under td-agent/apt directory.

### Note for AArch64 platforms

You can also built packages for AArch64 platforms like this:

```console
% rake yum:build APT_TARGETS="ubuntu-bionic-arm64"
```

But if you use older GNU/Linux platforms (e.g. Ubuntu 18.04 or before) as your host OS, you need to copy qemnu-aarch64-static into td-agent/yum/${TARGET}:

```console
% export TARGET="ubuntu-bionic-arm64"
% sudo apt install qemu-user-static
% cd /path/to/td-agent-builder
% cp /usr/bin/qemu-aarch64-static td-agent/apt/${TARGET}
% rake apt:build APT_TARGETS=${TARGET}
```

## How to build .msi package

```console
% rake msi:build
```

A td-agent-${version}-x64.msi package will be built under td-agent/msi directory.
