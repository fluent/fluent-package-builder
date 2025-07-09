#!/usr/bin/env rake
#
# fluent-package-builder
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#

PACKAGES = [
  "fluent-package",
]

APT_SOURCE_PACKAGES = [
  "fluent-apt-source",
  "fluent-lts-apt-source",
]

YUM_RELEASE_PACKAGES = [
  "fluent-release"
]

ALL_PACKAGE = [
  "fluent-package",
  "fluent-apt-source",
  "fluent-lts-apt-source",
  "fluent-release",
]

def define_bulked_task(name, description, packages = PACKAGES)
  desc description
  task name.to_sym do
    packages.each do |package|
      cd(package) do
        ruby("-S", "rake", name.to_s)
      end
    end
  end
end

[
  ["clean",            "Remove any temporary products", ALL_PACKAGE],
  ["clobber",          "Remove any generated files", ALL_PACKAGE],
  ["build:deb_config", "Create configuration files for Debian like systems"],
  ["build:rpm_config", "Create configuration files for Red Hat like systems with systemd"],
  ["build:all",        "Install all components"],
  ["apt:build",        "Build deb packages"],
  ["yum:build",        "Build RPM packages"],
  ["msi:build",        "Build MSI package (alias for msi:dockerbuild)"],
  ["msi:selfbuild",    "Build MSI package without using Docker"],
  ["msi:dockerbuild",  "Build MSI package by Docker"],
  ["dmg:selfbuild",    "Build macOS package without using Docker"],
].each do |params|
  define_bulked_task(*params)
end

[
  ["apt:build", "Build fluent-apt-source deb packages", APT_SOURCE_PACKAGES],
  ["yum:build", "Build fluent-release rpm packages", YUM_RELEASE_PACKAGES],
].each do |params|
  define_bulked_task(*params)
end

if ENV["INSTALLATION_TEST"]
  require "rspec/core/rake_task"
  namespace :serverspec do
    desc "Run serverspec on linux"
    RSpec::Core::RakeTask.new(:linux)  do |t|
      t.pattern = "serverspec/linux/*.rb"
    end

    desc "Run serverspec on windows"
    RSpec::Core::RakeTask.new(:windows)  do |t|
      t.pattern = "serverspec/windows/*.rb"
    end

    desc "Run serverspec for kafka"
    RSpec::Core::RakeTask.new(:kafka)  do |t|
      t.pattern = "serverspec/kafka/*.rb"
    end
  end
end
