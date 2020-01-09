#!/usr/bin/env rake
require 'fileutils'
require 'rake/testtask'
require 'rake/clean'
require_relative 'lib/td-agent-package-task'
require 'erb'
require 'shellwords'

def windows?
  RUBY_PLATFORM =~ /mswin|msys|mingw|cygwin|bccwin|wince|emc/
end

def macos?
  RUBY_PLATFORM =~ /darwin|mac os/
end

version = "3.5.1"
package_name = "td-agent"
pkg_type = ENV["PACKAGE_TYPE"] || "rpm"

workdir_prefix = ENV["TD_AGENT_GEM_HOME"] || "local"
git_workspace = "#{workdir_prefix}/git"
root_dir = if windows?
             "C:"
           else
             "/"
           end
install_dir_base = File.join("opt", package_name)
gem_install_dir = File.join("#{workdir_prefix}", "#{install_dir_base}")
mini_portile2 = Dir.glob(File.join(File.dirname(__FILE__), gem_install_dir, 'gems', 'mini_portile2-*', 'lib')).first
resources_path = 'resources'
package_scripts_path = "package-scripts"
install_message = nil


namespace :download do
  desc "download core_gems"
  task :core_gems do
    sh "bin/gem_downloader core_gems.rb"
  end

  desc "clone fluentd repository"
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
      sh "gem install --no-document #{gem_path} --install-dir #{gem_install_dir}"
    }
  end

  desc "fluentd installation"
  task :fluentd => [:"download:fluentd", :core_gems] do
    revision = nil
    cd git_workspace do
      cd "fluentd" do
        sh "git checkout #{revision}" if revision
        sh "rake build"
        sh "gem install --no-document pkg/fluentd-*.gem --install-dir #{gem_install_dir}"
      end
    end
  end

  desc "plugin_gems installation"
  task :plugin_gems => [:"download:plugin_gems", :fluentd] do
    Dir.glob(File.expand_path(File.join(__dir__, 'plugin_gems', '*.gem'))).sort.each { |gem_path|
      if gem_path.include?("rdkafka")
        sh "PATH=#{mini_portile2}:$PATH gem install --no-document #{gem_path} --install-dir #{gem_install_dir}"
      else
        sh "gem install --no-document #{gem_path} --install-dir #{gem_install_dir}"
      end
    }
  end

  desc "create configuration files from template"
  task :config do
    install_path = workdir_prefix
    package_dir_opt = File.join(root_dir, install_dir_base)
    template = ->(*parts) { File.join('templates', *parts) }
    generate_from_template = ->(dst, src, erb_binding, opts={}) {
      mode = opts.fetch(:mode, 0755)
      destination = dst.gsub('td-agent', package_name)
      FileUtils.mkdir_p File.dirname(destination)
      File.open(destination, 'w', mode) do |f|
        f.write ERB.new(File.read(src), nil, '<>').result(erb_binding)
      end
    }

    # copy pre/post scripts into omnibus path (./package-scripts/td-agentN)
    FileUtils.mkdir_p(package_scripts_path)
    Dir.glob(File.join(package_scripts_path, '*')).each { |f|
      FileUtils.rm_f(f) if File.file?(f)
    }
    # templates/package-scripts/td-agent/xxxx/* -> ./package-scripts/td-agentN
    Dir.glob(template.call('package-scripts', 'td-agent', pkg_type, '*')).each { |f|
      case pkg_type
      when "deb"
        package_script = File.join("debian", File.basename(f))
        generate_from_template.call package_script, f, binding, mode: 0755
      end
    }

    conf_paths = [
      ['td-agent', 'td-agent.conf'],
      ['td-agent', 'td-agent.conf.tmpl'],
      ['logrotate.d', 'td-agent.logrotate']
    ]
    conf_paths.each { |item|
      conf_path = File.join(resources_path, 'etc', *item)
      generate_from_template.call(conf_path, template.call('etc', *item), binding, mode: 0644)
    }

    unless macos?
      systemd_file_path = case pkg_type
                          when "rpm"
                            File.join(resources_path, 'usr', 'lib', 'systemd', 'system', package_name + ".service")
                          when "deb"
                            File.join(resources_path, 'etc', 'systemd', 'system', package_name + ".service")
                          end
      template_path = template.call('etc', 'systemd', 'td-agent.service.erb')
      if File.exist?(template_path)
        generate_from_template.call(systemd_file_path, template_path, binding, mode: 0755)
      end
    end

    ["td-agent", "td-agent-gem"].each { |command|
      sbin_path = File.join(install_path, 'usr', 'sbin', command)
      # templates/usr/sbin/yyyy.erb -> INSTALL_PATH/usr/sbin/yyyy
      generate_from_template.call(sbin_path, template.call('usr', 'sbin', "#{command}.erb"), binding, mode: 0755)
    }

    FileUtils.remove_entry_secure(File.join(install_path, 'etc'), true)
    # ./resources/etc -> INSTALL_PATH/etc
    FileUtils.cp_r(File.join('resources', 'etc'), install_path)
    if pkg_type == "rpm"
      # ./resources/usr -> INSTALL_PATH/usr
      FileUtils.cp_r(File.join('resources', 'usr'), install_path)
    end
  end
end

task :clean do
  rm_rf workdir_prefix
end

task = TDAgentPackageTask.new(package_name, version)
task.define
