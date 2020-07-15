dir 'core_gems'

download "bundler", "2.1.4"
download "msgpack", "1.3.3"
download "cool.io", "1.6.0"
download 'serverengine', '2.2.1'
download "oj", "3.10.6"
download "async-http", "0.52.4"
download "http_parser.rb", "0.6.0"
download "yajl-ruby", "1.4.1"
download "sigdump", "0.2.4"
download "tzinfo", "2.0.2"
download "tzinfo-data", "1.2020.1"

if windows?
  download 'ffi', '1.13.1'
  download 'ffi-win32-extensions', '1.0.3'
  download 'win32-ipc', '0.7.0'
  download 'win32-event', '0.6.3'
  download 'win32-service', '2.1.5'
  download 'win32-api', '1.9.1-universal-mingw32'
  download 'windows-pr', '1.2.6'
  download 'windows-api', '0.4.4'
end
