require 'rubygems'
require 'fluent/version'

fluent_package_config = File.expand_path(File.join(File.dirname(__FILE__), "../share/config"))
require fluent_package_config

puts "fluent-package #{PACKAGE_VERSION} fluentd #{Fluent::VERSION} (#{FLUENTD_REVISION})"
