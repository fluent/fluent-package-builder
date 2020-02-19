packages = [
  "td-agent",
]

desc "Remove any temporary products"
task :clean do
  packages.each do |package|
    cd(package) do
      ruby("-S", "rake", "clean")
    end
  end
end

desc "Remove any generated files"
task :clobber do
  packages.each do |package|
    cd(package) do
      ruby("-S", "rake", "clobber")
    end
  end
end

namespace :build do
  desc "Create configuration files for Debian like systems"
  task :deb_config do
    packages.each do |package|
      cd(package) do
        ruby("-S", "rake", "build:deb_config")
      end
    end
  end

  desc "Create configuration files for Red Hat like systems"
  task :rpm_config do
    packages.each do |package|
      cd(package) do
        ruby("-S", "rake", "build:rpm_config")
      end
    end
  end

  desc "Install all gems"
  task :gems do
    packages.each do |package|
      cd(package) do
        ruby("-S", "rake", "build:gems")
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

namespace :msi do
  desc "Build MSI package"
  task :build do
    packages.each do |package|
      cd(package) do
        ruby("-S", "rake", "msi:build")
      end
    end
  end
end
