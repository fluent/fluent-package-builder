# fluent-package-builder

## About fluent-package-builder

fluent-package-builder is a new build system for [td-agent](https://docs.treasuredata.com/display/public/PD/About+Treasure+Data%27s+Server-Side+Agent) which aims to replace the traditional build system [omnibus-td-agent](https://github.com/treasure-data/omnibus-td-agent) since it has several problems due to [Omnibus](https://github.com/chef/omnibus)'s limitations.

### Changes from Treasure Agent 3

* Use system libraries: e.g. openssl
* Remove libraries for 3rd party gems: e.g. postgresql
* Remove `embedded` directory by omnibus
  * Use `/opt/td-agent/bin/fluent-cat` instead of `/opt/td-agent/embedded/bin/fluent-cat`
* Update core components: ruby, jemalloc and more
* Add td-agent-apt-source deb package for maintaining apt-line and keyring
  * Download it and install by `apt install`, then you can install td-agent via `apt install td-agent`.
  * td-agent-apt-source deb package is created to install td-agent easily. Currently it points to td-agent 4 apt-line.

See also [this issue](https://github.com/treasure-data/omnibus-td-agent/issues/219) for omnibus problems.

## Prerequisites

### For building .rpm & .deb packages

  * Any host OS that is supported by Docker
    * Debian buster or Ubuntu 18.04 are recommended
  * [Docker](https://docs.docker.com/install/)
  * Ruby 2.5 or later
  * Bundler 2.2.0 or later
  * Git

### For building Windows package (.msi)

  * Windows OS (10 Pro or 2019 are verified)
  * [Docker Desktop for Windows](https://hub.docker.com/editions/community/docker-ce-desktop-windows)
    * You need to switch to "Windows containers" before using it.
  * [RubyInstaller](https://rubyinstaller.org/) 2.5 or later.
  * Bundler 2.2.0 or later
  * [Git for Windows](https://gitforwindows.org/)

After installed above software, you need to enable additional features from powershell (as admin).

```
dism.exe /online /enable-feature /featurename:Microsoft-Hyper-V /all /norestart
dism.exe /online /enable-feature /featurename:Containers /all /norestart
```

Then restart Windows.

### For building macOS package (.dmg)

  * macOS 10.15 (Catalina)
  * Ruby 2.5 or later
  * Bundler 2.2.0 or later
  * Git

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
% cd /path/to/fluent-package-builder
% cp /usr/bin/qemu-aarch64-static td-agent/yum/${TARGET_BASE}
% rake yum:build YUM_TARGETS="${TARGET_BASE}-aarch64"
```

### Note for ppc64le platform

You can also build packages for ppc64le platform like this:

```console
% rake yum:build YUM_TARGETS="centos-8-ppc64le"
```

But if you use older GNU/Linux platforms (e.g. Ubuntu 18.04 or before) as your host OS, you need to copy qemnu-ppc64le-static into the base directory of the target:

```console
% export TARGET_BASE="centos-8"
% sudo apt install qemu-user-static
% cd /path/to/fluent-package-builder
% cp /usr/bin/qemu-ppc64le-static td-agent/yum/${TARGET_BASE}
% rake yum:build YUM_TARGETS="${TARGET_BASE}-ppc64le"
```

## How to build .deb package

```console
% rake apt:build
```

By default, apt repositories for following platforms will be built under td-agent/apt/repositories/ directory:

  * Debian 10 "Buster" (x86_64)
  * Ubuntu 20.04 LTS "Focal Fossa" (x86_64)
  * Ubuntu 18.04 LTS "Bionic Beaver" (x86_64)
  * Ubuntu 16.04 LTS "Xenial Xerus" (x86_64)

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
% cd /path/to/fluent-package-builder
% cp /usr/bin/qemu-aarch64-static td-agent/apt/${TARGET_BASE}
% rake apt:build APT_TARGETS="${TARGET_BASE}-arm64"
```

## How to build .msi package

```console
% rake msi:build
```

A td-agent-${version}-x64.msi package will be built under td-agent/msi directory.

### Note for Windows package

You can use with [MSYS2](https://www.msys2.org/) for C extension gem building.

MSI included Ruby can detect MSYS2 environment.
So, you can install C extension included gem with MSYS2.

e.g.)

Prepare C extension gem building environment:

```console
cmd> ridk install 2
...
cmd> ridk install 3
```

Install gem via `ridk exec td-agent-gem install`:

```console
cmd> ridk exec td-agent-gem install winevt_c
```

## How to build .dmg package

```console
% rake dmg:selfbuild
```

A td-agent-${version}.dmg package will be built under td-agent/dmg directory.

### Note for macOS package

GitHub Actions' built package is ready to run on macOS 10.15 (Catalina).

Be sure to permit to be authrized for for assistive access.
In System Preferences > Security & Privacy > Privacy > Accessibility, you should permit Terminal.app there.

**NOTE:** Since authorization is at the application level on Terminal.app, it allows any script run from Terminal.app to perform GUI scripting.

## How to bump up the package version

* Edit td-agent/config.rb to choose Ruby & Fluentd versions
* Edit Gemfile and update .lock files
  * `cd td-agent && rake lockfile:update`
* Bump up the versions of rpm & deb packages by the following command:
```
% cd td-agent
% rake version:update
% git diff  # Check the change log
% git commit -a
```
* Build packages
```
% rake apt:build
% rake yum:build
% rake msi:build
```

### Note for bump up the package version

It assumes that Gemfile works with Bundler's multiplatform feature,
so bundler must be 2.2.0 or later.
