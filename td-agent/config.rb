PACKAGE_NAME = "td-agent"
PACKAGE_VERSION = "5.0.0"

FLUENTD_REVISION = 'e89092ce1132a933c12bb23fe8c9323c07ca81f5' # v1.15.3
FLUENTD_LOCAL_GEM_REPO = "file://" + File.expand_path(File.join(__dir__, "local_gem_repo"))

# https://github.com/jemalloc/jemalloc/releases
# Use jemalloc 3.x to reduce memory usage
# See https://github.com/fluent-plugins-nursery/fluent-package-builder/issues/305
JEMALLOC_VERSION = "3.6.0"
#JEMALLOC_VERSION = "5.2.1"

# https://www.openssl.org/source/
OPENSSL_VERSION = "1.1.1q"

BUNDLER_VERSION= "2.3.18"

# https://www.ruby-lang.org/en/downloads/ (tar.gz)
BUNDLED_RUBY_VERSION = "3.2.0"
BUNDLED_RUBY_SOURCE_SHA256SUM = "daaa78e1360b2783f98deeceb677ad900f3a36c0ffa6e2b6b19090be77abc272"

BUNDLED_RUBY_PATCHES = [
  # An example entry:
  # ["ruby-3.0/0001-ruby-resolv-Fix-confusion-of-received-response-messa.patch",   ["= 3.0.1"]],
]

# https://rubyinstaller.org/downloads/ (7-ZIP ARCHIVES)
BUNDLED_RUBY_INSTALLER_X64_VERSION = "3.2.0-1"
BUNDLED_RUBY_INSTALLER_X64_SHA256SUM = "c89a52859e9b008f73ad2bb2bce57b70b40ed90ccce68eefe16e49803bbb2c41"

# Patch files are assumed to be for Ruby's source tree, then applied to
# lib/ruby/x.y.0 in RubyInstaller. So that "-p2" options will be passed
# to patch command.
BUNDLED_RUBY_INSTALLER_PATCHES = [
  ["ruby-3.0/0001-ruby-resolv-Fix-confusion-of-received-response-messa.patch", ["= 2.7.3"]],
  ["ruby-3.0/0001-ruby-resolv-Fix-confusion-of-received-response-messa.patch", ["= 3.0.1"]],
]
