packages = [
  "td-agent",
]

task :clean do
  packages.each do |package|
    cd(package) do
      ruby("-S", "rake", "clean")
    end
  end
end

namespace :build do
  desc "create configuration files for Debian like systems"
  task :deb_config do
    packages.each do |package|
      cd(package) do
        ruby("-S", "rake", "build:deb_config")
      end
    end
  end

  desc "create configuration files for Red Hat like systems"
  task :rpm_config do
    packages.each do |package|
      cd(package) do
        ruby("-S", "rake", "build:rpm_config")
      end
    end
  end

  desc "plugin_gems installation"
  task :plugin_gems do
    packages.each do |package|
      cd(package) do
        ruby("-S", "rake", "build:plugin_gems")
      end
    end
  end
end

namespace :apt do
  desc "Build deb packages"
  task :build do
    packages.each do |package|
      cd(package) do
        ruby("-S", "rake", "apt:build")
      end
    end
  end
end

namespace :yum do
  desc "Build RPM packages"
  task :build do
    packages.each do |package|
      cd(package) do
        ruby("-S", "rake", "yum:build")
      end
    end
  end
end
