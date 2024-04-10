require_relative "../spec_helper"
require "json"
require "bundler"

describe package("fluent-package") do
  it { should be_installed }
end

if os[:family] == 'redhat'
  describe user("fluentd") do
    it { should exist }
    it { should belong_to_group "fluentd" }
  end

  describe group("fluentd") do
    it { should exist }
  end
else
  describe user("_fluentd") do
    it { should exist }
    it { should belong_to_group "_fluentd" }
  end

  describe group("_fluentd") do
    it { should exist }
  end
end

describe "gem files" do
  lock_path = File.join(File.dirname(File.dirname(File.dirname(__FILE__))),
                        "fluent-package/Gemfile.lock")
  gem_path = File.join(File.dirname(lock_path),
                       File.basename(lock_path, ".lock"))
  Bundler::Definition.build(gem_path, lock_path, false).dependencies.each do |spec|
    if spec.should_include?
      describe package("#{spec.name}") do
        it { should be_installed.by('gem') }
      end
    end
  end
end
