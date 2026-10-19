require "fiddle/import"

begin
  msys_path = RubyInstaller::Runtime.msys2_installation.msys_path
  abort "MSYS2 in #{msys_path} would hide DLLs missing from the package. Run this test without MSYS2."
rescue RubyInstaller::Runtime::Msys2Installation::MsysNotFound
end

module Kernel32
  extend Fiddle::Importer
  dlload "kernel32.dll"
  extern "void* LoadLibraryW(void*)"
end

ruby_api_version = RUBY_VERSION[/\A\d+\.\d+/]
for_other_ruby_version = ->(path) { path.split("/").any? { |dir| dir.match?(/\A\d+\.\d+\z/) && dir != ruby_api_version } }
libraries = Dir.glob("C:/opt/fluent/lib/ruby/**/*.so").reject(&for_other_ruby_version)
abort "No extension library is found." if libraries.empty?

failed = libraries.select do |path|
  wide_path = (path.tr("/", "\\") + "\0").encode("UTF-16LE")
  Kernel32.LoadLibraryW(wide_path).null?
end

failed.each do |path|
  puts "Failed to load: #{path}"
end
puts "Loaded #{libraries.size - failed.size}/#{libraries.size} extension libraries"
exit(failed.empty?)
