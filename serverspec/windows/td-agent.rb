require "serverspec"
set :backend, :cmd
set :os, :family => 'windows'
require "bundler"
require "win32/service"

class Specinfra::Command::Windows::Base::Package < Specinfra::Command::Windows::Base
  class << self
    def check_is_installed_by_gem(name, version=nil, gem_binary="gem")
      version_selection = version.nil? ? "" : "-gemVersion '#{version}'"
      Backend::PowerShell::Command.new do
        using "find_installed_gem.ps1"
        exec "(FindInstalledGem -gemName '#{name}' #{version_selection}) -eq $true"
      end
    end
  end
end

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
  Bundler::Definition.build(gem_path, lock_path, false).dependencies.each do |spec|
    if spec.should_include?
      describe package("#{spec.name}") do
        it { should be_installed.by("gem").with_version(spec.version) }
      end
    end
  end
end

describe "win32-service" do
  it "fluentdwinsvc" do
    expect(Win32::Service.services.collect(&:service_name).include?('fluentdwinsvc')).to eq true
  end
end
