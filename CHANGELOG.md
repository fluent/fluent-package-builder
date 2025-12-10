# Fluent Package 6 changelog

About the past changelog entries, see [CHANGELOG v4](CHANGELOG-v4.md) [CHANGELOG v5](CHANGELOG-v5.md) instead.

## Release v6.0.1 - 2025/11/11

### News

* Update Ruby to 3.4.7
* Update fluentd to 1.19.1
* Update bundled gems

### Core component

* ruby v3.4.7 (update)
* jemalloc v3.6.0
* OpenSSL 3.6.0 Windows
* OpenSSL 3.0.8 macOS
* gems
  * fluentd v1.19.1 (update)
  * msgpack 1.8.0
  * oj 3.16.11
  * webrick 1.9.1
  * openssl 3.3.0

### Bundled plugins and gems

* aws-partitions v1.1150.0
* aws-sdk-core v3.230.0
* aws-sdk-kms v1.110.0
* aws-sdk-s3 v1.197.0
* aws-sdk-sqs v1.101.0
* aws-sigv4 v1.12.1
* elasticsearch v8.19.2 (update)
* fluent-diagtool v1.0.5
* fluent-plugin-elasticsearch v6.0.0
* fluent-plugin-flowcounter-simple 0.1.0
* fluent-plugin-kafka v0.19.5
* fluent-plugin-metrics-cmetrics v0.1.2
* fluent-plugin-fluent-package-update-notifier 0.2.3
* fluent-plugin-obsolete-plugins v0.2.2
* fluent-plugin-opensearch v1.1.5
* fluent-plugin-opentelemetry 0.4.0 (update)
* fluent-plugin-prometheus v2.2.1
* fluent-plugin-prometheus_pushgateway v0.2.1
* fluent-plugin-record-modifier v2.2.1
* fluent-plugin-rewrite-tag-filter v2.4.0
* fluent-plugin-s3 v1.8.3
* fluent-plugin-sd-dns 0.1.0
* fluent-plugin-systemd v1.1.1
* fluent-plugin-td v1.2.0
* fluent-plugin-utmpx v0.5.0
* fluent-plugin-webhdfs v1.6.0
* mini_portile2 v2.8.9
* prometheus-client v4.2.5
* rdkafka v0.21.0
* ruby-kafka v1.5.0
* systemd-journal v2.1.1
* td-client v3.0.0
* webhdfs v0.11.0

On Windows

* fluent-plugin-parser-winevt_xml v0.2.8
* fluent-plugin-windows-exporter v1.0.0
* winevt_c v0.11.2
* nokogiri v1.18.10 (update)

## Release v6.0.0 - 2025/08/29

### News

* Update Ruby to 3.4.5
* Update fluentd to 1.19.0
* Update bundled gems

### Core component

* ruby v3.4.5 (update)
* jemalloc v3.6.0
* OpenSSL 3.5.1 Windows
* OpenSSL 3.0.8 macOS
* gems
  * fluentd v1.19.0 (update)
  * msgpack 1.8.0 (update)
  * oj 3.16.11 (update)
  * webrick 1.9.1 (update)
  * openssl 3.3.0

### Bundled plugins and gems

* aws-partitions v1.1150.0 (update)
* aws-sdk-core v3.230.0 (update)
* aws-sdk-kms v1.110.0 (update)
* aws-sdk-s3 v1.197.0 (update)
* aws-sdk-sqs v1.101.0 (update)
* aws-sigv4 v1.12.1 (update)
* elasticsearch v8.19.0 (update)
* fluent-diagtool v1.0.5
* fluent-plugin-elasticsearch v6.0.0 (update)
* fluent-plugin-fluent-package-notifier v0.1.0 (new)
* fluent-plugin-flowcounter-simple 0.1.0
* fluent-plugin-kafka v0.19.5 (update)
* fluent-plugin-metrics-cmetrics v0.1.2
* fluent-plugin-obsolete-plugins v0.2.2 (new)
* fluent-plugin-opensearch v1.1.5 (update)
* fluent-plugin-prometheus v2.2.1 (update)
* fluent-plugin-prometheus_pushgateway v0.2.1 (update)
* fluent-plugin-record-modifier v2.2.1 (update)
* fluent-plugin-rewrite-tag-filter v2.4.0
* fluent-plugin-s3 v1.8.3 (update)
* fluent-plugin-sd-dns 0.1.0
* fluent-plugin-systemd v1.1.1 (update)
* fluent-plugin-td v1.2.0
* fluent-plugin-utmpx v0.5.0
* fluent-plugin-webhdfs v1.6.0 (update)
* mini_portile2 v2.8.9 (update)
* prometheus-client v4.2.5 (update)
* rdkafka v0.21.0 (update)
* ruby-kafka v1.5.0
* systemd-journal v2.0.0 (update)
* td-client v3.0.0 (update)
* webhdfs v0.11.0 (update)
* fluent-plugin-opentelemetry 0.3.0 (new)
* fluent-plugin-fluent-package-update-notifier 0.2.3 (new)

On Windows

* fluent-plugin-parser-winevt_xml v0.2.8 (update)
* fluent-plugin-windows-exporter v1.0.0
* winevt_c v0.11.2 (update)
* nokogiri v1.18.9 (update)
