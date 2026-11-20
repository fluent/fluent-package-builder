PACKAGE_NAME = "fluent-package"
PACKAGE_VERSION = "6.1.1"

# Keep internal path (/opt/td-agent) for package name migration
SERVICE_NAME = "fluentd"
COMPAT_SERVICE_NAME = "td-agent"
PACKAGE_DIR = "fluent"
COMPAT_PACKAGE_DIR = COMPAT_SERVICE_NAME

FLUENTD_REVISION = '086fa170eb55f494289b10759cfca2a68f3ae87c' # v1.20.1 2026/10/26
FLUENTD_LOCAL_GEM_REPO = "file://" + File.expand_path(File.join(__dir__, "local_gem_repo"))

# https://github.com/jemalloc/jemalloc/releases
# Use jemalloc 3.x to reduce memory usage
# See https://github.com/fluent-plugins-nursery/fluent-package-builder/issues/305
#JEMALLOC_VERSION = "3.6.0"
JEMALLOC_VERSION = "5.3.1"

# https://www.openssl.org/source/
OPENSSL_FOR_MACOS_VERSION = "3.0.8"
OPENSSL_FOR_MACOS_SHA256SUM = "6c13d2bf38fdf31eac3ce2a347073673f5d63263398f1f69d0df4a41253e4b3e"

BUNDLER_VERSION= "4.0.20"

OPENSSL_FOR_LTS_VERSION = "3.5.8"
OPENSSL_FOR_LTS_SHA256SUM = "a8f84a39918ec6415ce765d9b429d313ba97b8143169c172e734b9514464f5b2"

# https://www.ruby-lang.org/en/downloads/ (tar.gz)
BUNDLED_RUBY_VERSION = "3.4.13"
BUNDLED_RUBY_SOURCE_SHA256SUM = "d0d3bf3dd8c224a3c3b7ecd816a0f1b2cbcf4f87b5afcbdbe91d3fef177f351a"

BUNDLED_RUBY_PATCHES = [
  # An example entry:
  # ["ruby-3.0/0001-ruby-resolv-Fix-confusion-of-received-response-messa.patch",   ["= 3.0.1"]],
]

# https://rubyinstaller.org/downloads/ (7-ZIP ARCHIVES)
BUNDLED_RUBY_INSTALLER_X64_VERSION = "3.4.13-1"
BUNDLED_RUBY_INSTALLER_X64_SHA256SUM = "228d698c2311dee6207017634faac64a07b7208cdc7a6a50972c4b19d9153a42"
BUNDLED_RUBY_INSTALLER_ARM64_VERSION = "3.4.13-1"
BUNDLED_RUBY_INSTALLER_ARM64_SHA256SUM = "1eadf2d39e17d2b3d3d7e6ee59da7f97220f96b1fe9eda8938e1c1f4dcdc8fdb"

# Files under rubyinstaller/ are patches for RubyInstaller's binary package.
# Other patches for Ruby's source tree which can be shared with BUNDLED_RUBY_PATCHES.
BUNDLED_RUBY_INSTALLER_PATCHES = [
]
