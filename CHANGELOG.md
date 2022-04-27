# Treasure Agent 4 changelog

## Release v4.3.1 - 2022/04/29

### News

* Update fluentd to v1.14.6
* Add some new plugins
  * fluent-plugin-opensearch v1.0.4
  * fluent-plugin-metrics-cmetrics v0.1.2
  * fluent-plugin-calyptia-monitoring v0.1.3
  * fluent-plugin-windows-exporter v1.0.0
* RPM: Remove .build-id directories

### Core component

* ruby v2.7.6
* jemalloc v3.6.0
* fluentd v1.14.6 (update)

### Core gems

* bundler v2.3.11 (update)
* msgpack v1.5.1 (update)
* cool.io v1.7.1
* serverengine v2.2.5 (update)
* oj v3.13.11 (update)
* async-http v0.56.5
* http_parser.rb v0.8.0
* yajl-ruby v1.4.2 (update)
* sigdump v0.2.4
* tzinfo v2.0.4
* tzinfo-data v1.2022.1 (update)

### Bundled plugins and gems

* td-client v1.0.8
* fluent-plugin-td v1.1.0
* aws-sdk-core v3.130.1 (update)
* aws-sdk-s3 v1.113.0 (update)
* fluent-plugin-s3 v1.6.1
* webhdfs v0.10.2
* fluent-plugin-webhdfs v1.5.0
* ruby-kafka v1.4.0
* rdkafka v0.11.1
* fluent-plugin-kafka v0.17.5 (update)
* elasticsearch v8.1.2 (update)
* fluent-plugin-elasticsearch v5.2.2 (update)
* prometheus-client v2.1.0
* fluent-plugin-prometheus v2.0.2
* fluent-plugin-prometheus_pushgateway v0.1.0
* systemd-journal v1.4.2
* fluent-plugin-systemd v1.0.5
* fluent-plugin-record-modifier v2.1.0
* fluent-plugin-rewrite-tag-filter v2.4.0
* fluent-plugin-sd-dns 0.1.0
* fluent-plugin-flowcounter-simple 0.1.0
* fluent-diagtool v1.0.1
* fluent-plugin-utmpx v0.5.0

On Windows

* winevt_c v0.9.3
* fluent-plugin-parser-winevt_xml v0.2.4
* fluent-plugin-windows-eventlog v0.8.1

## Release v4.3.0 - 2021/12/06

### News

* Support Debian 11 "bullseye"
* deb: Remove needless post-install script
* Windows: Add default log rotation setting

### Core component

* ruby v2.7.5 (update)
* jemalloc v3.6.0
* fluentd v1.14.3 (update)

### Core gems

* bundler v2.2.32 (update)
* msgpack v1.4.2
* cool.io v1.7.1
* serverengine v2.2.4
* oj v3.13.9 (update)
* async-http v0.56.5 (update)
* http_parser.rb v0.8.0 (update)
* yajl-ruby v1.4.1
* sigdump v0.2.4
* tzinfo v2.0.4
* tzinfo-data v1.2021.5 (update)

### Bundled plugins and gems

* td-client v1.0.8
* fluent-plugin-td v1.1.0
* aws-sdk-core v3.123.0 (update)
* aws-sdk-s3 v1.107.0 (update)
* fluent-plugin-s3 v1.6.1 (update)
* webhdfs v0.10.2 (update)
* fluent-plugin-webhdfs v1.5.0 (update)
* ruby-kafka v1.4.0 (update)
* rdkafka v0.11.1 (update)
* fluent-plugin-kafka v0.17.3 (update)
* elasticsearch v7.15.0 (update)
* fluent-plugin-elasticsearch v5.1.4 (update)
* prometheus-client v2.1.0
* fluent-plugin-prometheus v2.0.2 (update)
* fluent-plugin-prometheus_pushgateway v0.1.0
* systemd-journal v1.4.2
* fluent-plugin-systemd v1.0.5
* fluent-plugin-record-modifier v2.1.0
* fluent-plugin-rewrite-tag-filter v2.4.0
* fluent-plugin-sd-dns 0.1.0
* fluent-plugin-flowcounter-simple 0.1.0
* fluent-diagtool v1.0.1
* fluent-plugin-utmpx v0.5.0

On Windows

* winevt_c v0.9.3 (update)
* fluent-plugin-parser-winevt_xml v0.2.3 (update)
* fluent-plugin-windows-eventlog v0.8.1 (update)

## Release v4.2.0 - 2021/07/29

### News

* Downgrade jemalloc to v3.6.0 to reduce memory usage
  https://github.com/fluent-plugins-nursery/td-agent-builder/issues/305
* Remove needless perl dependency (jeprof command was removed)

### Core component

* ruby v2.7.4 (update)
* jemalloc v3.6.0 (downgrade)
* fluentd v1.13.3 (update)

### Core gems

* bundler v2.2.23 (update)
* msgpack v1.4.2
* cool.io v1.7.1
* serverengine v2.2.4 (update)
* oj v3.12.1 (update)
* async-http v0.56.3 (update)
* http_parser.rb v0.7.0 (update)
* yajl-ruby v1.4.1
* sigdump v0.2.4
* tzinfo v2.0.4
* tzinfo-data v1.2021.1

### Bundled plugins and gems

* td-client v1.0.8
* fluent-plugin-td v1.1.0
* aws-sdk-core v3.117.0 (update)
* aws-sdk-s3 v1.96.1 (update)
* fluent-plugin-s3 v1.6.0
* webhdfs v0.9.0
* fluent-plugin-webhdfs v1.4.0
* ruby-kafka v1.3.0
* rdkafka v0.9.0 (update)
* fluent-plugin-kafka v0.16.3 (update)
* elasticsearch v7.13.3 (update)
* fluent-plugin-elasticsearch v5.0.5 (update)
* prometheus-client v2.1.0 (update)
* fluent-plugin-prometheus v2.0.1 (update)
* fluent-plugin-prometheus_pushgateway v0.1.0 (update)
* systemd-journal v1.4.2 (update)
* fluent-plugin-systemd v1.0.5 (update)
* fluent-plugin-record-modifier v2.1.0
* fluent-plugin-rewrite-tag-filter v2.4.0
* fluent-plugin-sd-dns 0.1.0
* fluent-plugin-flowcounter-simple 0.1.0
* fluent-diagtool v1.0.1
* fluent-plugin-utmpx v0.5.0

On Windows

* winevt_c v0.9.2
* fluent-plugin-parser-winevt_xml v0.2.2
* fluent-plugin-windows-eventlog v0.8.0

## Release v4.1.1 - 2021/05/05

### News

* Remove unnecessary dependencies of RPM packages
* Fix uninstallable MSI package on non-English environment
* Fix broken td command executable
* Add fluent-plugin-utmpx gem to bundled plugins

### Core component

* ruby v2.7.3 (update)
* jemalloc v5.2.1
* fluentd v1.12.3 (update)
  * This version fixes some crash bugs of in_tail in v1.12.x

### Core gems

* bundler v2.2.16 (update)
* msgpack v1.4.2
* cool.io v1.7.1
* serverengine v2.2.3
* oj v3.11.5 (update)
* async-http v0.54.1
* http_parser.rb v0.6.0
* yajl-ruby v1.4.1
* sigdump v0.2.4
* tzinfo v2.0.4
* tzinfo-data v1.2021.1

### Bundled plugins and gems

* td-client v1.0.8 (update)
* fluent-plugin-td v1.1.0
* aws-sdk-core v3.114.0 (update)
* aws-sdk-s3 v1.93.1 (update)
* fluent-plugin-s3 v1.6.0 (update)
* webhdfs v0.9.0
* fluent-plugin-webhdfs v1.4.0
* ruby-kafka v1.3.0
* rdkafka v0.8.1
* fluent-plugin-kafka v0.16.1 (update)
* elasticsearch v7.12.0 (update)
* fluent-plugin-elasticsearch v5.0.3 (update)
* prometheus-client v0.9.0
* fluent-plugin-prometheus v1.8.5
* systemd-journal v1.3.3
* fluent-plugin-systemd v1.0.2
* fluent-plugin-record-modifier v2.1.0
* fluent-plugin-rewrite-tag-filter v2.4.0 (update)
* fluent-plugin-sd-dns 0.1.0
* fluent-plugin-flowcounter-simple 0.1.0
* fluent-diagtool v1.0.1

On Windows

* winevt_c v0.9.2 (update)
* fluent-plugin-parser-winevt_xml v0.2.2
* fluent-plugin-windows-eventlog v0.8.0

## Release v4.1.0 - 2021/02/24

### News

* Add fluent-diagtool gem to bundled gems
* Add fluent-plugin-sd-dns gem to bundled plugins
* Add fluent-plugin-flowcounter-simple gem to bundled plugins

### Core component

* ruby v2.7.2 (update)
* jemalloc v5.2.1
* fluentd v1.12.1 (update)

### Core gems

* bundler v2.2.11 (update)
* msgpack v1.4.2 (update)
* cool.io v1.7.1 (update)
* serverengine v2.2.3 (update)
* oj v3.10.8 (update)
* async-http v0.54.1 (update)
* http_parser.rb v0.6.0
* yajl-ruby v1.4.1
* sigdump v0.2.4
* tzinfo v2.0.4 (update)
* tzinfo-data v1.2021.1 (update)

### Bundled plugins and gems

* td-client v1.0.7
* fluent-plugin-td v1.1.0
* aws-sdk-core v3.112.0 (update)
* aws-sdk-s3 v1.75.0 (update)
* fluent-plugin-s3 v1.5.1 (update)
* webhdfs v0.9.0
* fluent-plugin-webhdfs v1.4.0 (update)
* ruby-kafka v1.3.0 (update)
* rdkafka v0.8.1 (update)
* fluent-plugin-kafka v0.16.0 (update)
* elasticsearch v7.8.1 (update)
* fluent-plugin-elasticsearch v4.1.1 (update)
* prometheus-client v0.9.0
* fluent-plugin-prometheus v1.8.5 (update)
* systemd-journal v1.3.3
* fluent-plugin-systemd v1.0.2
* fluent-plugin-record-modifier v2.1.0
* fluent-plugin-rewrite-tag-filter v2.3.0

On Windows

* winevt_c v0.9.1 (update)
* fluent-plugin-parser-winevt_xml v0.2.2
* fluent-plugin-windows-eventlog v0.8.0 (update)

## Release v4.0.1 - 2020/08/18

### News

* Fix jemalloc page size issue for Redhat 7/8 aarch64

### Core component

* ruby v2.7.1
* jemalloc v5.2.1
* fluentd v1.11.2 (update)

### Core gems

* bundler v2.1.4
* msgpack v1.3.3
* cool.io v1.6.0
* serverengine v2.2.1
* oj v3.10.6
* async-http v0.52.4
* http_parser.rb v0.6.0
* yajl-ruby v1.4.1
* sigdump v0.2.4
* tzinfo v2.0.2
* tzinfo-data v1.2020.1

### Bundled plugins and gems

* td-client v1.0.7
* fluent-plugin-td v1.1.0
* aws-sdk-core v3.104.3 (update)
* aws-sdk-s3 v1.75.0 (update)
* fluent-plugin-s3 v1.4.0 (update)
* webhdfs v0.9.0
* fluent-plugin-webhdfs v1.2.5
* ruby-kafka v1.2.0 (update)
* rdkafka v0.8.0
* fluent-plugin-kafka v0.14.1 (update)
* elasticsearch v7.8.1 (update)
* fluent-plugin-elasticsearch v4.1.1 (update)
* prometheus-client v0.9.0
* fluent-plugin-prometheus v1.8.2 (update)
* systemd-journal v1.3.3
* fluent-plugin-systemd v1.0.2
* fluent-plugin-record-modifier v2.1.0
* fluent-plugin-rewrite-tag-filter v2.3.0

On Windows

* winevt_c v0.8.1
* fluent-plugin-parser-winevt_xml v0.2.2
* fluent-plugin-windows-eventlog v0.7.0

## Release v4.0.0 - 2020/07/02

### News

* Support Arm64 architecture
  * Ubuntu xenial and Windows are excluded
* Support Ubuntu focal
* Drop CentOS 6 support

### Core component

* ruby v2.7.1
* jemalloc v5.2.1
* fluentd v1.11.1

### Core gems

* bundler v2.1.4
* msgpack v1.3.3
* cool.io v1.6.0
* serverengine v2.2.1
* oj v3.10.6
* async-http v0.52.4
* http_parser.rb v0.6.0
* yajl-ruby v1.4.1
* sigdump v0.2.4
* tzinfo v2.0.2
* tzinfo-data v1.2020.1

### Bundled plugins and gems

* td-client v1.0.7
* fluent-plugin-td v1.1.0
* aws-sdk-core v3.102.1
* aws-sdk-s3 v1.72.0
* fluent-plugin-s3 v1.3.3
* webhdfs v0.9.0
* fluent-plugin-webhdfs v1.2.5
* ruby-kafka v1.1.0
* rdkafka v0.8.0
* fluent-plugin-kafka v0.13.0
* elasticsearch v7.8.0
* fluent-plugin-elasticsearch v4.0.9
* prometheus-client v0.9.0
* fluent-plugin-prometheus v1.8.0
* systemd-journal v1.3.3
* fluent-plugin-systemd v1.0.2
* fluent-plugin-record-modifier v2.1.0
* fluent-plugin-rewrite-tag-filter v2.3.0

On Windows

* winevt_c v0.8.1
* fluent-plugin-parser-winevt_xml v0.2.3.rc1
* fluent-plugin-windows-eventlog v0.7.1.rc1
