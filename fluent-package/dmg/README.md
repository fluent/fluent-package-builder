# Building a macOS disk image locally

Local DMG builds are deprecated and no longer supported. The build task may
be removed in a future release. For installing Fluent Package on Apple Silicon
Macs, see the [Homebrew guide](../../homebrew/README.md).

## Prerequisites

* macOS
* Ruby, Bundler, and the `builder` gem
* Git and CMake
* Rust if building Ruby with YJIT

## Build

The build needs write access to `/opt/fluent`. On a dedicated build machine,
if that directory does not already exist, create it and assign it to your user:

```sh
sudo mkdir /opt/fluent
sudo chown "$(whoami)" /opt/fluent
```

From the repository root, run:

```sh
rake dmg:selfbuild
```

The task writes `fluent-package-<version>.dmg` under `fluent-package/dmg/`.
