PACKAGE_NAME = "fluent-package"
PACKAGE_VERSION = "5.0.2"

# Keep internal path (/opt/td-agent) for package name migration
SERVICE_NAME = "fluentd"
COMPAT_SERVICE_NAME = "td-agent"
PACKAGE_DIR = "fluent"
COMPAT_PACKAGE_DIR = COMPAT_SERVICE_NAME

FLUENTD_REVISION = 'd3cf2e0f95a0ad88b9897197db6c5152310f114f' # v1.16.3
FLUENTD_LOCAL_GEM_REPO = "file://" + File.expand_path(File.join(__dir__, "local_gem_repo"))

# https://github.com/jemalloc/jemalloc/releases
# Use jemalloc 3.x to reduce memory usage
# See https://github.com/fluent-plugins-nursery/fluent-package-builder/issues/305
JEMALLOC_VERSION = "3.6.0"
#JEMALLOC_VERSION = "5.2.1"

# https://www.openssl.org/source/
OPENSSL_FOR_MACOS_VERSION = "3.0.8"
OPENSSL_FOR_MACOS_SHA256SUM = "6c13d2bf38fdf31eac3ce2a347073673f5d63263398f1f69d0df4a41253e4b3e"

BUNDLER_VERSION= "2.3.26"

# https://www.ruby-lang.org/en/downloads/ (tar.gz)
BUNDLED_RUBY_VERSION = "3.2.2"
BUNDLED_RUBY_SOURCE_SHA256SUM = "96c57558871a6748de5bc9f274e93f4b5aad06cd8f37befa0e8d94e7b8a423bc"

BUNDLED_RUBY_PATCHES = [
  # An example entry:
  # ["ruby-3.0/0001-ruby-resolv-Fix-confusion-of-received-response-messa.patch",   ["= 3.0.1"]],
]

# https://rubyinstaller.org/downloads/ (7-ZIP ARCHIVES)
BUNDLED_RUBY_INSTALLER_X64_VERSION = "3.2.2-1"
BUNDLED_RUBY_INSTALLER_X64_SHA256SUM = "1f0f55ba0790676be6d701515a244159e9ca2d6314f1101560e3e8a277a2661e"

# Patch files are assumed to be for Ruby's source tree, then applied to
# lib/ruby/x.y.0 in RubyInstaller. So that "-p2" options will be passed
# to patch command.
BUNDLED_RUBY_INSTALLER_PATCHES = [
  # An example entry:
  # ["ruby-3.0/0001-ruby-resolv-Fix-confusion-of-received-response-messa.patch", ["= 3.0.1"]],
]
