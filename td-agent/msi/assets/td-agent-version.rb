require 'rubygems'
require 'fluent/version'

td_agent_config = File.expand_path(File.join(File.dirname(__FILE__), "../share/config"))
require td_agent_config

puts "td-agent #{PACKAGE_VERSION} fluentd #{Fluent::VERSION} (#{FLUENTD_REVISION})"
