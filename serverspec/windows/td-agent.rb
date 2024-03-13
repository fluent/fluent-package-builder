require "serverspec"
set :backend, :cmd
set :os, :family => 'windows'
require "bundler"
require "win32/service"
require "find"
require "digest/md5"

config_path = File.join(File.dirname(File.dirname(File.dirname(__FILE__))),
                        "fluent-package/config.rb")
require config_path

describe package("Fluent Package v#{PACKAGE_VERSION}") do
  it { should be_installed }
end

describe "gem files" do
  lock_path = File.join(File.dirname(File.dirname(File.dirname(__FILE__))),
                        "fluent-package/Gemfile.lock")
  gem_path = File.join(File.dirname(lock_path),
                       File.basename(lock_path, ".lock"))
  parser = Bundler::LockfileParser.new(Bundler.read_file(lock_path))
  Bundler::Definition.build(gem_path, lock_path, false).dependencies.each do |spec|
    if spec.should_include?
      gem = parser.specs.collect do |lock_spec| lock_spec if lock_spec.name == spec.name end.compact.first
      next unless gem
      describe package("#{gem.name}") do
        it { should be_installed.by("gem").with_version(gem.version) }
      end
    end
  end
end

describe "win32-service" do
  it "fluentdwinsvc" do
    expect(Win32::Service.services.collect(&:service_name).include?('fluentdwinsvc')).to eq true
  end

  it "forked version" do
    Find.find("c:/opt/fluent/lib/ruby/gems") do |f|
      if f.end_with?("win32-service-2.3.2/lib/win32/daemon.rb")
        expect(Digest::MD5.file(f).to_s).to eq "3cb1461c18ab2fd1e39d61c3169ac671".force_encoding("US-ASCII")
      elsif f.end_with?("win32-service-2.3.2/lib/win32/windows/functions.rb")
        expect(Digest::MD5.file(f).to_s).to eq "c40427a92dc1a7b6ba7808410535dd00".force_encoding("US-ASCII")
      end
    end
  end
end
