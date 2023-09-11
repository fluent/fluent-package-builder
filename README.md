# fluent-package-builder

## About fluent-package-builder

fluent-package-builder (formerly known as td-agent-builder, it was renamed at Aug, 2021) is a new build system for [td-agent](https://docs.treasuredata.com/display/public/PD/About+Treasure+Data%27s+Server-Side+Agent) which aims to replace the traditional build system [omnibus-td-agent](https://github.com/treasure-data/omnibus-td-agent) since it has several problems due to [Omnibus](https://github.com/chef/omnibus)'s limitations.

NOTE: Discussed why re-branding is required [Rebranding td-agent-builder](https://github.com/fluent/fluent-package-builder/issues/311)

### Changes from Treasure Agent 4

* `td-agent` was renamed to `fluent-package`
  * The content of `fluent-package` was changed to install under `/opt/fluent`
  * `/usr/sbin/td-agent` and `/usr/sbin/td-agent-gem` was changed to
  `/usr/sbin/fluentd` and `/usr/sbin/fluent-gem`
  * Changed the path of example default configuration file to `/opt/fluent/share/fluentd.conf`
* Debian 12 (bookworm) has been supported
* Removed Ubuntu 16.04 (xenial), Ubuntu 18.04 (bionic) support
* Amazon Linux 2023 has been supported
* Introduced new package signing key. The new key will be used in the future
  release. we still use using old signing key for a while
* `fluentd-apt-source` was renamed to `fluent-apt-source` deb package for maintaining apt-line and keyring

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
  * [Bundler](https://rubygems.org/gems/bundler) 2.2.0 or later
  * [Builder](https://rubygems.org/gems/builder) gem
  * Git
  * [CMake](https://cmake.org/)
  * [Rust](https://www.rust-lang.org/) to enable Ruby's YJIT feature

## How to build .rpm package

```console
% rake yum:build
```

By default, yum repositories for following platforms will be built under fluent-package/yum/repositories/ directory:

  * RHEL/CentOS 7 (x86_64)
  * RHEL/CentOS 8 (x86_64) - Built on Rocky Linux 8
  * RHEL/CentOS 9 (x86_64) - Built on AlmaLinux 9
  * Amazon Linux 2 (x86_64)
  * Amazon Linux 2023 (x86_64)

You can choose target platforms by `YUM_TARGETS` environment variable like this:

```console
% rake yum:build YUM_TARGETS="centos-7,rockylinux-8,almalinux-9"
```

You can find other supported platforms under fluent-package/yum directory.

### Note for AArch64 platforms

You can also build packages for AArch64 platforms like this:

```console
% rake yum:build YUM_TARGETS="amazonlinux-2023-aarch64"
```

But if you use older GNU/Linux platforms (e.g. Ubuntu 18.04 or before) as your host OS, you need to copy qemu-aarch64-static into the base directory of the target:

```console
% export TARGET_BASE="centos-8"
% sudo apt install qemu-user-static
% cd /path/to/fluent-package-builder
% cp /usr/bin/qemu-aarch64-static fluent-package/yum/${TARGET_BASE}
% rake yum:build YUM_TARGETS="${TARGET_BASE}-aarch64"
```

### Note for ppc64le platform

You can also build packages for ppc64le platform like this:

```console
% rake yum:build YUM_TARGETS="centos-8-ppc64le"
```

But if you use older GNU/Linux platforms (e.g. Ubuntu 18.04 or before) as your host OS, you need to copy qemu-ppc64le-static into the base directory of the target:

```console
% export TARGET_BASE="centos-8"
% sudo apt install qemu-user-static
% cd /path/to/fluent-package-builder
% cp /usr/bin/qemu-ppc64le-static fluent-package/yum/${TARGET_BASE}
% rake yum:build YUM_TARGETS="${TARGET_BASE}-ppc64le"
```

## How to build .deb package

```console
% rake apt:build
```

By default, apt repositories for following platforms will be built under fluent-package/apt/repositories/ directory:

  * Debian 11 "Bullseye" (x86_64)
  * Debian 12 "Bookworm" (x86_64)
  * Ubuntu 20.04 LTS "Focal Fossa" (x86_64)
  * Ubuntu 22.04 LTS "Jammy Jellyfish" (x86_64)

You can choose target platforms by `APT_TARGETS` environment variable like this:

```console
% rake apt:build APT_TARGETS="debian-bookworm,ubuntu-jammy"
```

You can find other supported platforms under fluent-package/apt directory.

### Note for AArch64 platforms

You can also built packages for AArch64 platforms like this:

```console
% rake apt:build APT_TARGETS="ubuntu-jammy-arm64"
```

But if you use older GNU/Linux platforms (e.g. Ubuntu 18.04 or before) as your host OS, you need to copy qemu-aarch64-static into the base directory of the target:

```console
% export TARGET_BASE="ubuntu-bionic"
% sudo apt install qemu-user-static
% cd /path/to/fluent-package-builder
% cp /usr/bin/qemu-aarch64-static fluent-package/apt/${TARGET_BASE}
% rake apt:build APT_TARGETS="${TARGET_BASE}-arm64"
```

## How to build .msi package

```console
% rake msi:build
```

A fluent-package-${version}-x64.msi package will be built under fluent-package/msi directory.

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

Install gem via `ridk exec fluent-gem install`:

```console
cmd> ridk exec fluent-gem install winevt_c
```

## How to build .dmg package

```console
% sudo mkdir /opt/fluent
% sudo chown $(whoami) /opt/fluent
% rake dmg:selfbuild
```

A fluent-package-${version}.dmg package will be built under fluent-package/dmg directory.

### Note for macOS package

GitHub Actions' built package is ready to run on macOS 10.15 (Catalina).

Be sure to permit to be authorized for for assistive access.
In System Preferences > Security & Privacy > Privacy > Accessibility, you should permit Terminal.app there.

**NOTE:** Since authorization is at the application level on Terminal.app, it allows any script run from Terminal.app to perform GUI scripting.

## How to bump up the package version

* Edit fluent-package/config.rb to choose Ruby & Fluentd versions
* Edit Gemfile and update .lock files
  * `cd fluent-package && rake lockfile:update`
* Bump up the versions of rpm & deb packages by the following command:
```
% cd fluent-package
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
