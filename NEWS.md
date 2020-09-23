# Td Agent Builder news

## Release v4.0.1 - 2020/08/18

### General

* Unified into `Gemfile` instead of `core_gems.rb` and `plugin_gems.rb`. [GitHub#142]
  - It simplify a management of bundled gem files. Note that
    this change requires newer bundler - bundler 2.2.0.rc1 or later.
* Added `lockfile:update` rake task to update lock file. [GitHub#161]
  - Execute `cd td-agent && rake lockfile:update` for updating bundled Gems.
* Added Serverspec test cases [GitHub#174, #180]
  - It was expected to reduce degraded bugs.

### Deb Packages

* Added `td-agent-apt-source` package to install apt key and .source [GitHub#181]
  - It enables `apt install td-agent-apt-source && apt install td-agent`.

### MSI Packages

* msi: Fixed a bug that required dll.a was removed unexpectedly.
  - This bug causes failure to build for C extensions. [GitHub#130]
* msi: Fixed to use TD_AGENT_TOPDIR in td-agent.conf. [GitHub#131]
  - It fixes the problem that c:/var is always created automatically.
    It was changed to respect installed directory (c:/opt/td-agent/var...)

### macOS

* macos: Added to support building macOS installer [GitHub#192]

## Release v4.0.0 - 2020/07/02

### General

* Migrated build system from Omnibus.

## Deb Packages

* Fixed to clean up lintian errors and warnings.

### RPM Packages

* Fixed to clean up rpmlint errors and warnings.
* Improved to support Amazon Linux 2. [GitHub#74]

### MSI Packages

* Improved to support install/uninstall Fluentd as fluentdwinsvc service. [GitHub#122]
