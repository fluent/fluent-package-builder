PACKAGE_NAME = "fluent-package"
PACKAGE_VERSION = "6.0.1"

# Keep internal path (/opt/td-agent) for package name migration
SERVICE_NAME = "fluentd"
COMPAT_SERVICE_NAME = "td-agent"
PACKAGE_DIR = "fluent"
COMPAT_PACKAGE_DIR = COMPAT_SERVICE_NAME

FLUENTD_REVISION = 'efdc4dca81c23480c9b55e13e55de6aa925b1cf5' # v1.19.1
FLUENTD_LOCAL_GEM_REPO = "file://" + File.expand_path(File.join(__dir__, "local_gem_repo"))

# https://github.com/jemalloc/jemalloc/releases
# Use jemalloc 3.x to reduce memory usage
# See https://github.com/fluent-plugins-nursery/fluent-package-builder/issues/305
JEMALLOC_VERSION = "3.6.0"
#JEMALLOC_VERSION = "5.2.1"

# https://www.openssl.org/source/
OPENSSL_FOR_MACOS_VERSION = "3.0.8"
OPENSSL_FOR_MACOS_SHA256SUM = "6c13d2bf38fdf31eac3ce2a347073673f5d63263398f1f69d0df4a41253e4b3e"

BUNDLER_VERSION= "2.3.27"

# https://www.ruby-lang.org/en/downloads/ (tar.gz)
BUNDLED_RUBY_VERSION = "3.4.7"
BUNDLED_RUBY_SOURCE_SHA256SUM = "23815a6d095696f7919090fdc3e2f9459b2c83d57224b2e446ce1f5f7333ef36"

BUNDLED_RUBY_PATCHES = [
  # An example entry:
  # ["ruby-3.0/0001-ruby-resolv-Fix-confusion-of-received-response-messa.patch",   ["= 3.0.1"]],
]

# https://rubyinstaller.org/downloads/ (7-ZIP ARCHIVES)
BUNDLED_RUBY_INSTALLER_X64_VERSION = "3.4.7-1"
BUNDLED_RUBY_INSTALLER_X64_SHA256SUM = "955678a8373c23e53032ac10f730a06120c7d3b956074020e57ca8b99b8930d4"

# Files under rubyinstaller/ are patches for RubyInstaller's binary package.
# Other patches for Ruby's source tree which can be shared with BUNDLED_RUBY_PATCHES.
BUNDLED_RUBY_INSTALLER_PATCHES = [
]
