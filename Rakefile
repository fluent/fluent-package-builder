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
  ["msi:build",        "Build MSI package (alias for msi:selfbuild)"],
  ["msi:selfbuild",    "Build MSI package"],
  ["msi:dockerbuild",  "Build MSI package by Docker"],
].each do |params|
  define_bulked_task(*params)
end
