PACKAGE_NAME = "fluent-package"
PACKAGE_VERSION = "6.1.0"

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
BUNDLED_RUBY_VERSION = "3.4.12"
BUNDLED_RUBY_SOURCE_SHA256SUM = "5e5d85ad93b0adcccbad47733680f4892bd0078e3342437f7babce01c1872479"

BUNDLED_RUBY_PATCHES = [
  # An example entry:
  # ["ruby-3.0/0001-ruby-resolv-Fix-confusion-of-received-response-messa.patch",   ["= 3.0.1"]],
]

# https://rubyinstaller.org/downloads/ (7-ZIP ARCHIVES)
BUNDLED_RUBY_INSTALLER_X64_VERSION = "3.4.12-1"
BUNDLED_RUBY_INSTALLER_X64_SHA256SUM = "3806f164377824bcb17e1cf39b17d967e2bdc01e8547ce0254cd786dbe2cfe13"
BUNDLED_RUBY_INSTALLER_ARM64_VERSION = "3.4.12-1"
BUNDLED_RUBY_INSTALLER_ARM64_SHA256SUM = "6462eea40a8399420708518b82d121eec0d24daf5bb64abdf238a54d85362d29"

# Files under rubyinstaller/ are patches for RubyInstaller's binary package.
# Other patches for Ruby's source tree which can be shared with BUNDLED_RUBY_PATCHES.
BUNDLED_RUBY_INSTALLER_PATCHES = [
]
