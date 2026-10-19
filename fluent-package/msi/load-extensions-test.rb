require "fiddle/import"

module Kernel32
  extend Fiddle::Importer
  dlload "kernel32.dll"
  extern "void* LoadLibraryExW(void*, void*, unsigned long)"
end

# Ruby loads extension libraries with this flag.
LOAD_WITH_ALTERED_SEARCH_PATH = 0x8

ruby_api_version = RUBY_VERSION[/\A\d+\.\d+/]
libraries = Dir.glob("C:/opt/fluent/lib/ruby/**/*.so").reject do |path|
  # Binary gems also have libraries for other Ruby versions.
  path =~ %r{/lib/(\d+\.\d+)/[^/]+\.so\z} && $1 != ruby_api_version
end

failed = libraries.select do |path|
  wide_path = (path.tr("/", "\\") + "\0").encode("UTF-16LE")
  Kernel32.LoadLibraryExW(wide_path, nil, LOAD_WITH_ALTERED_SEARCH_PATH).null?
end

failed.each do |path|
  puts "Failed to load: #{path}"
end
puts "Loaded #{libraries.size - failed.size}/#{libraries.size} extension libraries"
exit(failed.empty?)
