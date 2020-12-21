require "serverspec"
set :backend, :cmd
set :os, :family => 'windows'
require "bundler"
require "win32/service"

config_path = File.join(File.dirname(File.dirname(File.dirname(__FILE__))),
                        "td-agent/config.rb")
require config_path

describe package("td-agent v#{PACKAGE_VERSION}") do
  it { should be_installed }
end

describe "gem files" do
  lock_path = File.join(File.dirname(File.dirname(File.dirname(__FILE__))),
                        "td-agent/Gemfile.lock")
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
end
