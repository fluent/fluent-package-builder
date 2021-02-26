# Treasure Agent 4 changelog

## Release v4.1.0 - 2020/02/24

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
