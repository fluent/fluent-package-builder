# Fluent Package 5 changelog

About the past changelog entries, see [old CHANGELOG](CHANGELOG-v4.md) instead.

## Release v6.0.0 - 2025/08/29

### News

* Update Ruby to 3.4.4
* Update fluentd to 1.19.0
* Update bundled gems

### Core component

* ruby v3.4.4 (update)
* jemalloc v3.6.0
* OpenSSL 3.4.0 Windows
* OpenSSL 3.0.8 macOS
* gems
  * fluentd v1.19.0 (update)
  * msgpack 1.8.0 (update)
  * oj 3.16.11 (update)
  * webrick 1.9.1 (update)
  * openssl 3.3.0

### Bundled plugins and gems

* aws-partitions v1.1110.0 (update)
* aws-sdk-core v3.225.0 (update)
* aws-sdk-kms v1.102.0 (update)
* aws-sdk-s3 v1.189.0 (update)
* aws-sdk-sqs v1.96.0 (update)
* aws-sigv4 v1.12.0 (update)
* elasticsearch v9.0.3 (update)
* fluent-diagtool v1.0.5
* fluent-plugin-elasticsearch v6.0.0 (update)
* fluent-plugin-fluent-package-notifier v0.1.0 (new)
* fluent-plugin-flowcounter-simple 0.1.0
* fluent-plugin-kafka v0.19.4 (update)
* fluent-plugin-metrics-cmetrics v0.1.2
* fluent-plugin-obsolete-plugins v0.1.1 (new)
* fluent-plugin-opensearch v1.1.5 (update)
* fluent-plugin-prometheus v2.2.1 (update)
* fluent-plugin-prometheus_pushgateway v0.2.1 (update)
* fluent-plugin-record-modifier v2.2.0 (update)
* fluent-plugin-rewrite-tag-filter v2.4.0
* fluent-plugin-s3 v1.8.3 (update)
* fluent-plugin-sd-dns 0.1.0
* fluent-plugin-systemd v1.1.0 (update)
* fluent-plugin-td v1.2.0
* fluent-plugin-utmpx v0.5.0
* fluent-plugin-webhdfs v1.6.0 (update)
* mini_portile2 v2.8.9 (update)
* prometheus-client v4.2.4 (update)
* rdkafka v0.21.0 (update)
* ruby-kafka v1.5.0
* systemd-journal v2.0.0 (update)
* td-client v2.0.0 (update)
* webhdfs v0.11.0 (update)

On Windows

* fluent-plugin-parser-winevt_xml v0.2.8 (update)
* fluent-plugin-windows-exporter v1.0.0
* winevt_c v0.11.2 (update)
* nokogiri v1.18.8 (update)

## Release v5.0.7 - 2025/05/16

### News

* Update Ruby to 3.2.8 (#816)
* Update fluentd to 1.16.9 (#816)
* Update bundled gems

### Core component

* ruby v3.2.8 (update)
* jemalloc v3.6.0
* OpenSSL 3.4.0 Windows
* OpenSSL 3.0.8 macOS
* gems
  * fluentd v1.16.9 (update)
  * msgpack 1.7.5
  * oj 3.16.5
  * webrick 1.8.2
  * openssl 3.3.0 (update)

### Bundled plugins and gems

* aws-partitions v1.785.0
* aws-sdk-core v3.178.0
* aws-sdk-kms v1.71.0
* aws-sdk-s3 v1.129.0
* aws-sdk-sqs v1.61.0
* aws-sigv4 v1.6.0
* elasticsearch v8.8.0
* fluent-diagtool v1.0.5
* fluent-plugin-calyptia-monitoring v0.1.3
* fluent-plugin-elasticsearch v5.4.4 (update)
* fluent-plugin-flowcounter-simple 0.1.0
* fluent-plugin-kafka v0.19.3
* fluent-plugin-metrics-cmetrics v0.1.2
* fluent-plugin-opensearch v1.1.4
* fluent-plugin-prometheus v2.1.0
* fluent-plugin-prometheus_pushgateway v0.1.1
* fluent-plugin-record-modifier v2.1.1
* fluent-plugin-rewrite-tag-filter v2.4.0
* fluent-plugin-s3 v1.7.2
* fluent-plugin-sd-dns 0.1.0
* fluent-plugin-systemd v1.1.0
* fluent-plugin-td v1.2.0
* fluent-plugin-utmpx v0.5.0
* fluent-plugin-webhdfs v1.5.0
* mini_portile2 v2.8.2
* prometheus-client v2.1.0
* rdkafka v0.12.0
* ruby-kafka v1.5.0
* systemd-journal v2.0.0
* td-client v1.0.8
* webhdfs v0.10.2

On Windows

* fluent-plugin-parser-winevt_xml v0.2.7
* fluent-plugin-windows-exporter v1.0.0
* winevt_c v0.10.2
* nokogiri v1.16.8

## Release v5.0.6 - 2025/02/14

### News

* Update Ruby to 3.2.7 (#783)
* Update fluentd to 1.16.7 (#783)
* Update bundled gems
* msi: Fixed to keep some registry values with update (#779)

### Core component

* ruby v3.2.7 (update)
* jemalloc v3.6.0
* OpenSSL 3.4.0 Windows
* OpenSSL 3.0.8 macOS
* fluentd v1.16.7 (update)
* msgpack 1.7.5 (update)
* oj 3.16.5
* webrick 1.8.2

### Bundled plugins and gems

* aws-partitions v1.785.0
* aws-sdk-core v3.178.0
* aws-sdk-kms v1.71.0
* aws-sdk-s3 v1.129.0
* aws-sdk-sqs v1.61.0
* aws-sigv4 v1.6.0
* elasticsearch v8.8.0
* fluent-diagtool v1.0.5
* fluent-plugin-calyptia-monitoring v0.1.3
* fluent-plugin-elasticsearch v5.4.0
* fluent-plugin-flowcounter-simple 0.1.0
* fluent-plugin-kafka v0.19.3 (update)
* fluent-plugin-metrics-cmetrics v0.1.2
* fluent-plugin-opensearch v1.1.4
* fluent-plugin-prometheus v2.1.0
* fluent-plugin-prometheus_pushgateway v0.1.1
* fluent-plugin-record-modifier v2.1.1
* fluent-plugin-rewrite-tag-filter v2.4.0
* fluent-plugin-s3 v1.7.2
* fluent-plugin-sd-dns 0.1.0
* fluent-plugin-systemd v1.1.0
* fluent-plugin-td v1.2.0
* fluent-plugin-utmpx v0.5.0
* fluent-plugin-webhdfs v1.5.0
* mini_portile2 v2.8.2
* prometheus-client v2.1.0
* rdkafka v0.12.0
* ruby-kafka v1.5.0
* systemd-journal v2.0.0
* td-client v1.0.8
* webhdfs v0.10.2

On Windows

* fluent-plugin-parser-winevt_xml v0.2.7
* fluent-plugin-windows-exporter v1.0.0
* winevt_c v0.10.2 (update)
* nokogiri v1.16.8 (update)

## Release v5.2.0 - 2024/12/14

### News

* Update bundled Ruby to 3.2.6
* Update bundled Fluentd to v1.18.0
* Update bundled gems
* deb rpm: Fixed to not execute v4 restart migration process unexpectedly.
* msi: set GEM_HOME/GEM_PATH in fluentd.bat
* Support upgrade fluentd service with zero downtime.
  Note that you can use this feature when upgrade to the next version of fluent-package.
* fluentd.service: Remove GEM_HOME/GEM_PATH env vars because they are unnecessary. 
* deb: suppress service restart by needrestart.
  The package places `/etc/needrestart/conf.d/50-fluent-package.conf`.
This is standard version of Fluentd distribution package.
If you want LTS version, stick to use v5.0.x.

### Core component

* ruby v3.2.6 (update)
* jemalloc v3.6.0
* OpenSSL 3.1.0 Windows
* OpenSSL 3.0.8 macOS
* fluentd v1.18.0 (update)

### Core gems

* async-http v0.64.2
* bundler v2.3.26
* cool.io v1.8.1
* http_parser.rb v0.8.0
* msgpack v1.7.3 (update)
* oj v3.16.7 (update)
* serverengine v2.4.0 (update)
* sigdump v0.2.5
* tzinfo v2.0.6
* tzinfo-data v1.2024.2 (update)
* yajl-ruby v1.4.3

### Bundled plugins and gems

* aws-partitions v1.957.0
* aws-sdk-core v3.201.2
* aws-sdk-kms v1.88.0
* aws-sdk-s3 v1.156.0
* aws-sdk-sqs v1.80.0
* aws-sigv4 v1.8.0
* elasticsearch v8.14.0
* fluent-diagtool v1.0.5
* fluent-plugin-calyptia-monitoring v0.1.3
* fluent-plugin-elasticsearch v5.4.3
* fluent-plugin-flowcounter-simple 0.1.0
* fluent-plugin-kafka v0.19.3
* fluent-plugin-metrics-cmetrics v0.1.2
* fluent-plugin-opensearch v1.1.4
* fluent-plugin-prometheus v2.1.0
* fluent-plugin-prometheus_pushgateway v0.1.1
* fluent-plugin-record-modifier v2.2.0
* fluent-plugin-rewrite-tag-filter v2.4.0
* fluent-plugin-s3 v1.8.1 (update)
* fluent-plugin-sd-dns 0.1.0
* fluent-plugin-systemd v1.1.0 (update)
* fluent-plugin-td v1.2.0
* fluent-plugin-utmpx v0.5.0
* fluent-plugin-webhdfs v1.6.0
* mini_portile2 v2.8.2
* prometheus-client v4.1.0
* rdkafka v0.16.1
* ruby-kafka v1.5.0
* systemd-journal v2.0.0 (update)
* td-client v1.0.8
* webhdfs v0.11.0

On Windows

* fluent-plugin-parser-winevt_xml v0.2.7
* fluent-plugin-windows-exporter v1.0.0
* winevt_c v0.11.1 (update)
* nokogiri v1.16.8 (update)

## Release v5.0.5 - 2024/11/08

### News

* Update ruby to 3.2.6 (#697)
* Update fluentd to 1.16.6 (#697)
* Update bundled gems

### Core component

* ruby v3.2.6 (update)
* jemalloc v3.6.0
* OpenSSL 3.4.0 Windows (update)
* OpenSSL 3.0.8 macOS
* fluentd v1.16.6 (update)
* msgpack 1.7.3 (update)
* oj 3.16.5 (update)
* webrick 1.8.2 (update)

### Bundled plugins and gems

* aws-partitions v1.785.0
* aws-sdk-core v3.178.0
* aws-sdk-kms v1.71.0
* aws-sdk-s3 v1.129.0
* aws-sdk-sqs v1.61.0
* aws-sigv4 v1.6.0
* elasticsearch v8.8.0
* fluent-diagtool v1.0.5
* fluent-plugin-calyptia-monitoring v0.1.3
* fluent-plugin-elasticsearch v5.4.0
* fluent-plugin-flowcounter-simple 0.1.0
* fluent-plugin-kafka v0.19.2
* fluent-plugin-metrics-cmetrics v0.1.2
* fluent-plugin-opensearch v1.1.4
* fluent-plugin-prometheus v2.1.0
* fluent-plugin-prometheus_pushgateway v0.1.1
* fluent-plugin-record-modifier v2.1.1
* fluent-plugin-rewrite-tag-filter v2.4.0
* fluent-plugin-s3 v1.7.2
* fluent-plugin-sd-dns 0.1.0
* fluent-plugin-systemd v1.1.0 (update)
* fluent-plugin-td v1.2.0
* fluent-plugin-utmpx v0.5.0
* fluent-plugin-webhdfs v1.5.0
* mini_portile2 v2.8.2
* prometheus-client v4.1.0
* rdkafka v0.12.0
* ruby-kafka v1.5.0
* systemd-journal v2.0.0 (update)
* td-client v1.0.8
* webhdfs v0.10.2

On Windows

* fluent-plugin-parser-winevt_xml v0.2.7
* fluent-plugin-windows-exporter v1.0.0
* winevt_c v0.10.1
* nokogiri v1.16.6

## Release v5.1.0 - 2024/07/29

### News

* Update bundled Ruby to 3.2.5
* Update bundled Fluentd to v1.17.0
* Update bundled gems

This is standard version of Fluentd distribution package.
If you want LTS version, stick to use v5.0.x.

### Core component

* ruby v3.2.5 (update)
* jemalloc v3.6.0
* OpenSSL 3.1.0 Windows
* OpenSSL 3.0.8 macOS
* fluentd v1.17.0

### Core gems

* async-http v0.64.2 (update)
* bundler v2.3.26
* cool.io v1.8.1 (update)
* http_parser.rb v0.8.0
* msgpack v1.7.2
* oj v3.16.4 (update)
* serverengine v2.3.2
* sigdump v0.2.5
* tzinfo v2.0.6
* tzinfo-data v1.2024.1
* yajl-ruby v1.4.3

### Bundled plugins and gems

* aws-partitions v1.957.0 (update)
* aws-sdk-core v3.201.2 (update)
* aws-sdk-kms v1.88.0 (update)
* aws-sdk-s3 v1.156.0 (update)
* aws-sdk-sqs v1.80.0 (update)
* aws-sigv4 v1.8.0 (update)
* elasticsearch v8.14.0 (update)
* fluent-diagtool v1.0.5
* fluent-plugin-calyptia-monitoring v0.1.3
* fluent-plugin-elasticsearch v5.4.3
* fluent-plugin-flowcounter-simple 0.1.0
* fluent-plugin-kafka v0.19.3 (update)
* fluent-plugin-metrics-cmetrics v0.1.2
* fluent-plugin-opensearch v1.1.4
* fluent-plugin-prometheus v2.1.0
* fluent-plugin-prometheus_pushgateway v0.1.1
* fluent-plugin-record-modifier v2.2.0 (update)
* fluent-plugin-rewrite-tag-filter v2.4.0
* fluent-plugin-s3 v1.7.2
* fluent-plugin-sd-dns 0.1.0
* fluent-plugin-systemd v1.0.5
* fluent-plugin-td v1.2.0
* fluent-plugin-utmpx v0.5.0
* fluent-plugin-webhdfs v1.6.0 (update)
* mini_portile2 v2.8.2
* prometheus-client v4.1.0
* rdkafka v0.16.1 (update)
* ruby-kafka v1.5.0
* systemd-journal v1.4.2
* td-client v1.0.8
* webhdfs v0.11.0 (update)

On Windows

* fluent-plugin-parser-winevt_xml v0.2.7
* fluent-plugin-windows-exporter v1.0.0
* winevt_c v0.11.0 (update)
* nokogiri v1.16.7 (update)

## Release v5.0.4 - 2024/06/29

### News

* Update ruby to 3.2.4 (#645)
* Update bundled gems
* Ubuntu 24.04 LTS (Noble Numbat) has been supported (#639)
* Fixed to prevent launching Fluentd wrongly if the service is already running (#648,#649)
* msi: fixed not to override `PATH` environment variable accidentally (#647)
* CentOS 7 was dropped (#651,#654)

### Core component

* ruby v3.2.4 (update)
* jemalloc v3.6.0
* OpenSSL 3.1.0 Windows
* OpenSSL 3.0.8 macOS
* fluentd v1.16.5

### Core gems

* async-http v0.61.0
* bundler v2.3.26
* cool.io v1.8.0
* http_parser.rb v0.8.0
* msgpack v1.7.2
* oj v3.16.1
* serverengine v2.3.2
* sigdump v0.2.5
* tzinfo v2.0.6
* tzinfo-data v1.2024.1
* yajl-ruby v1.4.3

### Bundled plugins and gems

* aws-partitions v1.785.0
* aws-sdk-core v3.178.0
* aws-sdk-kms v1.71.0
* aws-sdk-s3 v1.129.0
* aws-sdk-sqs v1.61.0
* aws-sigv4 v1.6.0
* elasticsearch v8.8.0
* fluent-diagtool v1.0.5
* fluent-plugin-calyptia-monitoring v0.1.3
* fluent-plugin-elasticsearch v5.4.0
* fluent-plugin-flowcounter-simple 0.1.0
* fluent-plugin-kafka v0.19.2
* fluent-plugin-metrics-cmetrics v0.1.2
* fluent-plugin-opensearch v1.1.4
* fluent-plugin-prometheus v2.1.0
* fluent-plugin-prometheus_pushgateway v0.1.1
* fluent-plugin-record-modifier v2.1.1
* fluent-plugin-rewrite-tag-filter v2.4.0
* fluent-plugin-s3 v1.7.2
* fluent-plugin-sd-dns 0.1.0
* fluent-plugin-systemd v1.0.5
* fluent-plugin-td v1.2.0
* fluent-plugin-utmpx v0.5.0
* fluent-plugin-webhdfs v1.5.0
* mini_portile2 v2.8.2
* prometheus-client v4.1.0
* rdkafka v0.12.0
* ruby-kafka v1.5.0
* systemd-journal v1.4.2
* td-client v1.0.8
* webhdfs v0.10.2

On Windows

* fluent-plugin-parser-winevt_xml v0.2.7
* fluent-plugin-windows-exporter v1.0.0
* winevt_c v0.10.1
* nokogiri v1.16.6 (update)

## Release v5.0.3 - 2024/03/29

### News

* Update fluentd to 1.16.5
* Update bundled gems
* msi: fixed wrong environment path for Fluent Package Prompt (#606)
  * It breaks fluent-diagtool behavior to launch fluent-gem correctly.
* msi: removed unnecessary path delimiter (#607)
  * It doesn't cause any problem yet, but it should treat `%~dp0` correctly.
* rpm: fixed to take over enabled state of systemd service from td-agent v4 (#613)
* deb rpm: fixed to quote target files correctly not to cause migration failures (#615)
* msi: added a patch for RubyInstaller to avoid crash on start up (#620)
* msi: fixed slow start issue on Windows (#631)
* Update fluent-diagtool to v1.0.5
  * Supports to collect list of plugins on Windows.
  * Fixed not to raise an exception when sysctl is missing on Linux.
* msi: changed to stop running migration process on every update (#641)
  In the previous versions, this will copy the old `td-agent.conf` file to `fluentd.conf` again.
  This results in the loss of the current config.

### Core component

* ruby v3.2.3 (update)
* jemalloc v3.6.0
* OpenSSL 3.1.0 Windows
* OpenSSL 3.0.8 macOS
* fluentd v1.16.4 (update)

### Core gems

* async-http v0.61.0
* bundler v2.3.27
* cool.io v1.8.0
* http_parser.rb v0.8.0
* msgpack v1.7.2
* oj v3.16.1
* serverengine v2.3.2
* sigdump v0.2.5
* tzinfo v2.0.6
* tzinfo-data v1.2024.1 (update)
* yajl-ruby v1.4.3

### Bundled plugins and gems

* aws-partitions v1.785.0
* aws-sdk-core v3.178.0
* aws-sdk-kms v1.71.0
* aws-sdk-s3 v1.129.0
* aws-sdk-sqs v1.61.0
* aws-sigv4 v1.6.0
* elasticsearch v8.8.0
* fluent-diagtool v1.0.5 (update)
* fluent-plugin-calyptia-monitoring v0.1.3
* fluent-plugin-elasticsearch v5.4.0
* fluent-plugin-flowcounter-simple 0.1.0
* fluent-plugin-kafka v0.19.2
* fluent-plugin-metrics-cmetrics v0.1.2
* fluent-plugin-opensearch v1.1.4
* fluent-plugin-prometheus v2.1.0
* fluent-plugin-prometheus_pushgateway v0.1.1
* fluent-plugin-record-modifier v2.1.1
* fluent-plugin-rewrite-tag-filter v2.4.0
* fluent-plugin-s3 v1.7.2
* fluent-plugin-sd-dns 0.1.0
* fluent-plugin-systemd v1.0.5
* fluent-plugin-td v1.2.0
* fluent-plugin-utmpx v0.5.0
* fluent-plugin-webhdfs v1.5.0
* mini_portile2 v2.8.2
* prometheus-client v4.1.0
* rdkafka v0.12.0
* ruby-kafka v1.5.0
* systemd-journal v1.4.2
* td-client v1.0.8
* webhdfs v0.10.2

On Windows

* fluent-plugin-parser-winevt_xml v0.2.7 (update)
* fluent-plugin-windows-exporter v1.0.0
* winevt_c v0.10.1
* nokogiri v1.16.2 (update)

## Release v5.0.2 - 2023/11/29

### News

* Update fluentd to 1.16.3
* Update bundled gems
* msi: support path which contains space or parenthesis (#589)
* deb: fixed system user/group name in logrotate config (#592,#594)
  * It fixes a bug that unknown user error was reported.
* rpm: fixed to create fluentd user as system account (#596)
  * It fixes a bug that /var/lib/fluent directory was created unexpectedly.
* rpm: changed to keep system account after removing fluent-package. (#598)
  * In the previous versions, there was a bug that group was not cleanly removed
    when the package was upgraded from td-agent v4.
    This change makes reinstall/downgrade friendly.
* Update fluent-diagtool to v1.0.3
  * Supports fluent-package.
  * Supports Windows partially.
  * Adds the feature to confirm the manually installed plugin list.

### Core component

* ruby v3.2.2
* jemalloc v3.6.0
* OpenSSL 3.1.0 Windows
* OpenSSL 3.0.8 macOS
* fluentd v1.16.3 (update)

### Core gems

* async-http v0.61.0 (update)
* bundler v2.3.26
* cool.io v1.8.0 (update)
* http_parser.rb v0.8.0
* msgpack v1.7.2 (update)
* oj v3.16.1 (update)
* serverengine v2.3.2
* sigdump v0.2.5
* tzinfo v2.0.6
* tzinfo-data v1.2023.3
* yajl-ruby v1.4.3

### Bundled plugins and gems

* aws-partitions v1.785.0
* aws-sdk-core v3.178.0
* aws-sdk-kms v1.71.0
* aws-sdk-s3 v1.129.0
* aws-sdk-sqs v1.61.0
* aws-sigv4 v1.6.0
* elasticsearch v8.8.0
* fluent-diagtool v1.0.3 (update)
* fluent-plugin-calyptia-monitoring v0.1.3
* fluent-plugin-elasticsearch v5.4.0 (update)
* fluent-plugin-flowcounter-simple 0.1.0
* fluent-plugin-kafka v0.19.2 (update)
* fluent-plugin-metrics-cmetrics v0.1.2
* fluent-plugin-opensearch v1.1.4 (update)
* fluent-plugin-prometheus v2.1.0
* fluent-plugin-prometheus_pushgateway v0.1.1
* fluent-plugin-record-modifier v2.1.1
* fluent-plugin-rewrite-tag-filter v2.4.0
* fluent-plugin-s3 v1.7.2
* fluent-plugin-sd-dns 0.1.0
* fluent-plugin-systemd v1.0.5
* fluent-plugin-td v1.2.0
* fluent-plugin-utmpx v0.5.0
* fluent-plugin-webhdfs v1.5.0
* mini_portile2 v2.8.2
* prometheus-client v4.1.0
* rdkafka v0.12.0
* ruby-kafka v1.5.0
* systemd-journal v1.4.2
* td-client v1.0.8
* webhdfs v0.10.2

On Windows

* fluent-plugin-parser-winevt_xml v0.2.6
* fluent-plugin-windows-eventlog v0.8.3
* fluent-plugin-windows-exporter v1.0.0
* winevt_c v0.10.1
* nokogiri v1.15.5 (update)

## Release v5.0.1 - 2023/08/29

### News

**fluent-package v5.0.1 is a GA (General Availability) version of fluent-package v5 series.**

In v5.0.1, minor bug and security related issue was fixed.

* deb: cleanup /var/run correctly when removing `fluent-package`.
* Update bundled protocol-http1 to 0.15.1 to reduce attack vector (HTTP
  Request/Response smuggling vulnerability). See [CVE-2023-38697](https://nvd.nist.gov/vuln/detail/CVE-2023-38697).
  GitHub advisory was also published as [GHSA-6jwc-qr2q-7xwj](https://github.com/advisories/GHSA-6jwc-qr2q-7xwj).

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
* fluent-plugin-windows-eventlog v0.8.3
* fluent-plugin-windows-exporter v1.0.0
* winevt_c v0.10.1
* nokogiri v1.15.3 (update)
