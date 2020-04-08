dir 'plugin_gems'

download "httpclient", "2.8.2.4"
download "td-client", "1.0.7"
download "td", "0.16.8"
download "fluent-plugin-td", "1.1.0"

download "jmespath", "1.4.0"
download "aws-partitions", "1.288.0"
download "aws-sigv4", "1.1.1"
download "aws-sdk-core", "3.92.0"
download "aws-sdk-kms", "1.30.0"
download "aws-sdk-sqs", "1.24.0"
download "aws-sdk-s3", "1.61.1"
download "fluent-plugin-s3", "1.3.0"

download "webhdfs", "0.9.0"
download "fluent-plugin-webhdfs", "1.2.4"

download "fluent-plugin-rewrite-tag-filter", "2.3.0"

download "ruby-kafka", "1.0.0"
unless windows?
  download "rdkafka", "0.7.0"
end
download "fluent-plugin-kafka", "0.13.0"

download "elasticsearch", "7.6.0"
download "fluent-plugin-elasticsearch", "4.0.7"
download "prometheus-client", "0.9.0"
download "fluent-plugin-prometheus", "1.7.3"
download "fluent-plugin-prometheus_pushgateway", "0.0.2"

download "fluent-plugin-record-modifier", "2.1.0"

unless windows?
  download "systemd-journal", "1.3.3"
  download "fluent-plugin-systemd", "1.0.2"
end

if windows?
  download 'win32-eventlog', '0.6.7'
  download 'winevt_c', '0.7.4'
  download 'fluent-plugin-windows-eventlog', '0.5.4'
end
