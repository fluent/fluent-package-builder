PACKAGE_NAME = "fluent-package"
PACKAGE_VERSION = "6.0.5"

# Keep internal path (/opt/td-agent) for package name migration
SERVICE_NAME = "fluentd"
COMPAT_SERVICE_NAME = "td-agent"
PACKAGE_DIR = "fluent"
COMPAT_PACKAGE_DIR = COMPAT_SERVICE_NAME

FLUENTD_REVISION = '43c860907e3d6a92c922233fd16eb2ed9ea16b69' # v1.19.3 (Jun 25)
FLUENTD_LOCAL_GEM_REPO = "file://" + File.expand_path(File.join(__dir__, "local_gem_repo"))

# https://github.com/jemalloc/jemalloc/releases
# Use jemalloc 3.x to reduce memory usage
# See https://github.com/fluent-plugins-nursery/fluent-package-builder/issues/305
JEMALLOC_VERSION = "3.6.0"
#JEMALLOC_VERSION = "5.2.1"

# https://www.openssl.org/source/
OPENSSL_FOR_MACOS_VERSION = "3.0.8"
OPENSSL_FOR_MACOS_SHA256SUM = "6c13d2bf38fdf31eac3ce2a347073673f5d63263398f1f69d0df4a41253e4b3e"

BUNDLER_VERSION= "2.7.2"

# https://www.ruby-lang.org/en/downloads/ (tar.gz)
BUNDLED_RUBY_VERSION = "3.4.11"
BUNDLED_RUBY_SOURCE_SHA256SUM = "5c22be44524312b3d433d68739bcc530633b1da5ef8ba0afa0a37680da17d3de"

BUNDLED_RUBY_PATCHES = [
  # An example entry:
  # ["ruby-3.0/0001-ruby-resolv-Fix-confusion-of-received-response-messa.patch",   ["= 3.0.1"]],
]

# https://rubyinstaller.org/downloads/ (7-ZIP ARCHIVES)
BUNDLED_RUBY_INSTALLER_X64_VERSION = "3.4.11-1"
BUNDLED_RUBY_INSTALLER_X64_SHA256SUM = "a9aca84326a90422c0905bcb47be629b687a881dcad96149604c2cb074d03154"

# Files under rubyinstaller/ are patches for RubyInstaller's binary package.
# Other patches for Ruby's source tree which can be shared with BUNDLED_RUBY_PATCHES.
BUNDLED_RUBY_INSTALLER_PATCHES = [
]
