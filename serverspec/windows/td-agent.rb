require "serverspec"
set :backend, :cmd
set :os, :family => 'windows'
require "bundler"

config_path = File.join(File.dirname(File.dirname(File.dirname(__FILE__))),
                        "td-agent/config.rb")
File.open(config_path) do |file|
  eval(file.read)
end

describe package("td-agent v#{PACKAGE_VERSION}") do
  it { should be_installed }
end

describe "gem files" do
  lock_path = File.join(File.dirname(File.dirname(File.dirname(__FILE__))),
                        "gemfiles/windows/Gemfile.lock")
  parser = Bundler::LockfileParser.new(Bundler.read_file(lock_path))
  parser.specs.each do |spec|
    describe package("#{spec.name}") do
      it { should be_installed.by('gem') }
    end
  end
end
