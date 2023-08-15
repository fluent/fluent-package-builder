# Fluent Package 5 changelog

About the past changelog entries, see [old CHANGELOG](CHANGELOG-v4.md) instead.

## Release v5.0.0 - 2023/07/28

### News

**fluent-package v5.0.0 is a RC (Release Candidate) version of fluent-package v5 series. We are planning to publish GA (General Availability) version of v5 series at the end of Aug 2023.**

* `td-agent` is renamed to `fluent-package`. (#448,#449,#463,#518)
  * This represents current community-oriented development styles well.
* Debian 12 (bookworm) has been supported. (#462,#509)
* Removed Ubuntu 16.04 (xenial), Ubuntu 18.04 (bionic) support. (#457,#509)
* Amazon Linux 2023 has been supported. (#459)
* Introduced new package signing key. The new key will be used in the future
  release. we still use using old signing key for a while. (#507)

Not only changing package name, but also there are some notable changes.
Basically, for `td-agent` v4 users, it aims to keep compatibility as far as possible
by executing the migration process with copying old files or providing
symbolic links for it.

If you created custom service units, you must manually modify the old file to the new path.
For example, you must update such as: `D_PRELOAD`, `GEM_HOME`, `GEM_PATH`, path of `fluentd` and so on.

#### For all platform:

* The content of `fluent-package` changed to install under `/opt/fluent`. (e.g. `c:/opt/fluent` for windows) (#464)
* During upgrade install process from v4, it respects the old content
  and path of log files as far as possible. (#489,#500,#505)
* `/usr/sbin/td-agent` and `/usr/sbin/td-agent-gem` was changed to
  `/usr/sbin/fluentd` and `/usr/sbin/fluent-gem`. For backward
  compatibility, the symbolic link is provided for upgrade users. (#531)
* Changed the path of example default configuration file to `/opt/fluent/share/fluentd.conf`. (#525,#528)

#### For Debian/Ubuntu user:

* Debian 12 (bookworm) has been supported. (#462,#509)
* Removed Ubuntu 16.04 (xenial), Ubuntu 18.04 (bionic) support. (#457,#509)
* deb: the service file is changed to `fluentd.service`.
  It provides `td-agent` as an alias. Note that if you
  want to keep using `td-agent` as a service name, you must
  explicitly execute the following commands: (#461,#516)
  
  ```
  $ sudo systemctl stop td-agent
  $ (upgrade to fluent-package...)
  $ sudo systemctl unmask td-agent
  $ sudo systemctl enable --now fluentd
  ```
  
* deb: user/group name was changed to `_fluentd`. This change is
  introduced to follow Debian policy. For backward compatibility, if 
  you upgraded from v4, `td-agent` user/group remains as same
  `UID`/`GID` of `_fluentd`. This change makes easy to
  keep using `/etc/logrotate.d/td-agent` as is.  (#475,#519)
  * Note that process or file owner of `fluent-package` is displayed
    as `td-agent` instead of `fluentd`.
* deb: the path of service configuration file is changed to
  `/etc/default/fluentd`. (#461)
* deb: `fluentd-apt-source` was renamed to `fluent-apt-source`.
  * You can remove transitional `fluentd-apt-source` after upgrading
    to `fluent-apt-source`. (#507,#514,#515)
* deb: for LTS users, added `fluent-lts-apt-source` package (#541)

#### For RHEL user:

* rpm: the service file is changed to `fluentd.service`.
  It provides `td-agent` as an alias. Note that if you
  want to keep using `td-agent` as a service name, you must
  explicitly execute the following commands: (#461,#516)
  
  ```
  $ sudo systemctl enable fluentd
  ```

* rpm: user/group name was changed to fluentd. For backward
  compatibility, if you upgraded from v4, `td-agent` user/group
  remains as same `UID`/`GID` of `fluentd`. This change makes easy to
  keep using `/etc/logrotate.d/td-agent` as is. (#475,#519)
  * Note that process or file owner of `fluent-package` is displayed
    as `td-agent` instead of `fluentd`.
* rpm: the path of service configuration file is changed to
  `/etc/sysconfig/fluentd`. (#461)
* rpm: prelink configuration was removed. (#472,#529)
  * In recent days, it is common to disable prelink configuration. If
  you upgrade from v4, that configuration file
  (`/etc/sysconfig/prelink.conf.d/td-agent-ruby.conf`) itself will be
  removed or the entry about `td-agent` will be removed from
  `/etc/sysconfig/prelink.conf`.
* rpm: added support for Amazon Linux 2023. (#459)
* rpm: fixed build failure on CentOS 7 aarch64 (#545)

#### For Windows user:

* msi: renamed to "Fluent Package" (#463,#466,#471)
* msi: the default install path of `fluent-package` was changed to `c:/opt/fluent`.
  Note that old log files are kept as is. The following files are migrated to the
  new path: (#466,#469,#487)
  
  * `c:/opt/td-agent/etc/td-agent/td-agent.conf`
  * `c:/opt/td-agent/etc/plugins/*`
* msi: the prefix of batch files were renamed to `fluent*`.
  Thus `td-agent-prompt.bat` was renamed to `fluent-package-prompt.bat`. (#484)
* msi: disable auto starting service after install. (#521)

  * If you want to start `fluentd` as a service, execute the following command with administrator privileges.
  
  ```
  > net start fluentdwinsvc
  ```

* msi: stop customizing icons for file browser (#469)
* msi: update resources for `fluent-package` (#470)
* msi: changed the default path of buffer/failed_records (#527)

#### For macOS user:

WARNING: Currently we have no plan to release dmg version of `fluent-package` yet.
It is just modified to be a minimally buildable state, it is for testing purpose only.

* dmg: renamed to `fluent-package` (#474,#478,#479,#480,#481,#482,#483)
  * Note that the .dmg package support will be dropped in the future
  release. We plans to migrate for `homebrew` ecosystem.
* dms: update resources for `fluent-package` (#473)

### Core component

* ruby v3.2.2 (update)
* jemalloc v3.6.0
* OpenSSL 3.1.0 Windows (update)
* OpenSSL 3.0.8 macOS (update)
* fluentd v1.16.2

### Core gems

* async-http v0.60.2 (update)
* bundler v2.3.26
* cool.io v1.7.1
* http_parser.rb v0.8.0
* msgpack v1.7.1 (update)
* oj v3.15.0 (update)
* serverengine v2.3.2
* sigdump v0.2.5 (update)
* tzinfo v2.0.6
* tzinfo-data v1.2023.3
* yajl-ruby v1.4.3

### Bundled plugins and gems

* aws-partitions v1.785.0 (update)
* aws-sdk-core v3.178.0 (update)
* aws-sdk-kms v1.71.0 (update)
* aws-sdk-s3 v1.129.0 (update)
* aws-sdk-sqs v1.61.0 (update)
* aws-sigv4 v1.6.0 (update)
* elasticsearch v8.8.0 (update)
* fluent-diagtool v1.0.1
* fluent-plugin-calyptia-monitoring v0.1.3
* fluent-plugin-elasticsearch v5.3.0
* fluent-plugin-flowcounter-simple 0.1.0
* fluent-plugin-kafka v0.19.0
* fluent-plugin-metrics-cmetrics v0.1.2
* fluent-plugin-opensearch v1.1.3 (update)
* fluent-plugin-prometheus v2.1.0 (update)
* fluent-plugin-prometheus_pushgateway v0.1.1 (update)
* fluent-plugin-record-modifier v2.1.1
* fluent-plugin-rewrite-tag-filter v2.4.0
* fluent-plugin-s3 v1.7.2
* fluent-plugin-sd-dns 0.1.0
* fluent-plugin-systemd v1.0.5
* fluent-plugin-td v1.2.0
* fluent-plugin-utmpx v0.5.0
* fluent-plugin-webhdfs v1.5.0
* mini_portile2 v2.8.2 (update)
* prometheus-client v4.1.0 (update)
* rdkafka v0.12.0 (update)
* ruby-kafka v1.5.0
* systemd-journal v1.4.2
* td-client v1.0.8
* webhdfs v0.10.2

On Windows

* fluent-plugin-parser-winevt_xml v0.2.6 (update)
* fluent-plugin-windows-eventlog v0.8.3 (update)
* fluent-plugin-windows-exporter v1.0.0
* winevt_c v0.10.1
* nokogiri v1.15.3 (update)
