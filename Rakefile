#!/usr/bin/env rake
#
# td-agent-builder
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
  "td-agent",
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
  ["clean",            "Remove any temporary products"],
  ["clobber",          "Remove any generated files"],
  ["build:deb_config", "Create configuration files for Debian like systems"],
  ["build:rpm_config", "Create configuration files for Red Hat like systems"],
  ["build:gems",       "Install all gems"],
  ["apt:build",        "Build deb packages"],
  ["yum:build",        "Build RPM packages"],
  ["msi:build",        "Build MSI package (alias for msi:dockerbuild)"],
  ["msi:selfbuild",    "Build MSI package without using Docker"],
  ["msi:dockerbuild",  "Build MSI package by Docker"],
].each do |params|
  define_bulked_task(*params)
end
