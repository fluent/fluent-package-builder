#!/usr/bin/env rake
require 'fileutils'
require 'rake/testtask'
require 'rake/clean'
require_relative 'td-agent-package-task'

workdir_prefix = ENV["TD_AGENT_GEM_HOME"] || "local"
git_workspace = "#{workdir_prefix}/git"
ENV["GEM_HOME"] = "#{workdir_prefix}/opt/td-agent"
mini_portile2 = Dir.glob(File.join(File.dirname(__FILE__), ENV["GEM_HOME"], 'gems', 'mini_portile2-*', 'lib')).first
version = "3.5.1"
distname = "td-agent-builder-#{version}.tar.gz"

namespace :download do
  desc "download core_gems"
  task :core_gems do
    sh "bin/gem_downloader core_gems.rb"
  end

  desc "clone fluentd repoditory"
  task :fluentd do
    revision = nil
    mkdir_p git_workspace
    cd git_workspace do
      sh "git clone https://github.com/fluent/fluentd.git" unless File.exists?("fluentd")
    end
  end

  desc "download plugin_gems"
  task :plugin_gems do
    sh "bin/gem_downloader plugin_gems.rb"
  end
end

namespace :build do
  desc "core_gems installation"
  task :core_gems => :"download:core_gems" do
    Dir.glob(File.expand_path(File.join(__dir__, 'core_gems', '*.gem'))).sort.each { |gem_path|
      sh "gem install --no-document #{gem_path}"
    }
  end

  desc "fluentd installation"
  task :fluentd => [:"download:fluentd", :core_gems] do
    revision = nil
    cd git_workspace do
      cd "fluentd" do
        sh "git checkout #{revision}" if revision
        sh "rake build"
        sh "gem install --no-document pkg/fluentd-*.gem"
      end
    end
  end

  desc "plugin_gems installation"
  task :plugin_gems => [:"download:plugin_gems", :fluentd] do
    Dir.glob(File.expand_path(File.join(__dir__, 'plugin_gems', '*.gem'))).sort.each { |gem_path|
      if gem_path.include?("rdkafka")
        sh "PATH=#{mini_portile2}:$PATH gem install --no-document #{gem_path}"
      else
        sh "gem install --no-document #{gem_path}"
      end
    }
  end
end

task :dist do
  sh "git archive HEAD -o #{distname}"
end

task :clean do
  rm_rf workdir_prefix
  rm_f distname
end

task = TDAgentPackageTask.new(version)
task.define
