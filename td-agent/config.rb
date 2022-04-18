PACKAGE_NAME = "td-agent"
PACKAGE_VERSION = "4.3.1"

FLUENTD_REVISION = 'c0f48a0080550eff6aa6fa19d269e480684e7a45' # v1.14.6
FLUENTD_LOCAL_GEM_REPO = "file://" + File.expand_path(File.join(__dir__, "local_gem_repo"))

# https://github.com/jemalloc/jemalloc/releases
# Use jemalloc 3.x to reduce memory usage
# See https://github.com/fluent-plugins-nursery/fluent-package-builder/issues/305
JEMALLOC_VERSION = "3.6.0"
#JEMALLOC_VERSION = "5.2.1"

# https://www.openssl.org/source/
OPENSSL_VERSION = "1.1.1n"

BUNDLER_VERSION= "2.3.11"

# https://www.ruby-lang.org/en/downloads/ (tar.gz)
BUNDLED_RUBY_VERSION = "2.7.5"
BUNDLED_RUBY_SOURCE_SHA256SUM = "2755b900a21235b443bb16dadd9032f784d4a88f143d852bc5d154f22b8781f1"
#BUNDLED_RUBY_VERSION = "3.0.3"
#BUNDLED_RUBY_SOURCE_SHA256SUM = "3586861cb2df56970287f0fd83f274bd92058872d830d15570b36def7f1a92ac"
#BUNDLED_RUBY_VERSION = "3.1.1"
#BUNDLED_RUBY_SOURCE_SHA256SUM = "fe6e4782de97443978ddba8ba4be38d222aa24dc3e3f02a6a8e7701c0eeb619d"

BUNDLED_RUBY_PATCHES = [
  ["ruby-2.7/0001-Removed-the-old-executables-of-racc.patch",            ["~> 2.7.0"]],
  ["ruby-2.7/0002-Fixup-a6864f6d2f39bcd1ff04516591cc18d4027ab186.patch", ["~> 2.7.0"]],
  ["ruby-3.0/0001-ruby-resolv-Fix-confusion-of-received-response-messa.patch",   ["= 2.7.3"]],
  ["ruby-3.0/0001-ruby-resolv-Fix-confusion-of-received-response-messa.patch",   ["= 3.0.1"]],
]

# https://rubyinstaller.org/downloads/ (7-ZIP ARCHIVES)
BUNDLED_RUBY_INSTALLER_X64_VERSION = "2.7.5-1"
BUNDLED_RUBY_INSTALLER_X64_SHA256SUM = "abe14d4d71ee058d5349557827af6bcf90a99344032822ad113c0922b24fad56"
#BUNDLED_RUBY_INSTALLER_X64_VERSION = "3.0.3-1"
#BUNDLED_RUBY_INSTALLER_X64_SHA256SUM = "30642b62de19f96c9ba3b4082690950bd1971b178527ad5af02accd2bbf0302e"
#BUNDLED_RUBY_INSTALLER_X64_VERSION = "3.1.1-1"
#BUNDLED_RUBY_INSTALLER_X64_SHA256SUM = "8635aa0cffe3326a376a3e519b41373967268f5570a8dd7fbc6353904ff78bc5"

# Patch files are assumed to be for Ruby's source tree, then applied to
# lib/ruby/x.y.0 in RubyInstaller. So that "-p2" options will be passed
# to patch command.
BUNDLED_RUBY_INSTALLER_PATCHES = [
  ["ruby-3.0/0001-ruby-resolv-Fix-confusion-of-received-response-messa.patch", ["= 2.7.3"]],
  ["ruby-3.0/0001-ruby-resolv-Fix-confusion-of-received-response-messa.patch", ["= 3.0.1"]],
]
