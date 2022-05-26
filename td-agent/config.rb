PACKAGE_NAME = "td-agent"
PACKAGE_VERSION = "4.3.1.1"

FLUENTD_REVISION = 'c0f48a0080550eff6aa6fa19d269e480684e7a45' # v1.14.6
FLUENTD_LOCAL_GEM_REPO = "file://" + File.expand_path(File.join(__dir__, "local_gem_repo"))

# https://github.com/jemalloc/jemalloc/releases
# Use jemalloc 3.x to reduce memory usage
# See https://github.com/fluent-plugins-nursery/fluent-package-builder/issues/305
JEMALLOC_VERSION = "3.6.0"
#JEMALLOC_VERSION = "5.2.1"

# https://www.openssl.org/source/
OPENSSL_VERSION = "1.1.1n"

# To fix memory leak issue: https://github.com/fluent/fluent-package-builder/issues/374
MINGW_OPENSSL_VERSION = "1.1.1.o-2"
MINGW_OPENSSL_SHA256SUM = "e1e642d441de3d6b9d4e499b42bb5464458e3a2d2431012b28e6f1ad94099167"

BUNDLER_VERSION= "2.3.11"

# https://www.ruby-lang.org/en/downloads/ (tar.gz)
BUNDLED_RUBY_VERSION = "2.7.6"
BUNDLED_RUBY_SOURCE_SHA256SUM = "e7203b0cc09442ed2c08936d483f8ac140ec1c72e37bb5c401646b7866cb5d10"
#BUNDLED_RUBY_VERSION = "3.0.4"
#BUNDLED_RUBY_SOURCE_SHA256SUM = "70b47c207af04bce9acea262308fb42893d3e244f39a4abc586920a1c723722b"
#BUNDLED_RUBY_VERSION = "3.1.2"
#BUNDLED_RUBY_SOURCE_SHA256SUM = "61843112389f02b735428b53bb64cf988ad9fb81858b8248e22e57336f24a83e"

BUNDLED_RUBY3_VERSION = "3.1.2"
BUNDLED_RUBY3_SOURCE_SHA256SUM = "61843112389f02b735428b53bb64cf988ad9fb81858b8248e22e57336f24a83e"

BUNDLED_RUBY_PATCHES = [
  ["ruby-2.7/0001-Removed-the-old-executables-of-racc.patch",            ["~> 2.7.0"]],
  ["ruby-2.7/0002-Fixup-a6864f6d2f39bcd1ff04516591cc18d4027ab186.patch", ["~> 2.7.0"]],
  ["ruby-3.0/0001-ruby-resolv-Fix-confusion-of-received-response-messa.patch",   ["= 2.7.3"]],
  ["ruby-3.0/0001-ruby-resolv-Fix-confusion-of-received-response-messa.patch",   ["= 3.0.1"]],
]

# https://rubyinstaller.org/downloads/ (7-ZIP ARCHIVES)
BUNDLED_RUBY_INSTALLER_X64_VERSION = "2.7.6-1"
BUNDLED_RUBY_INSTALLER_X64_SHA256SUM = "7c74064a4c410a866e37dc04bf35945dc1c7c313f32a4bf773e145662bbc285a"
#BUNDLED_RUBY_INSTALLER_X64_VERSION = "3.0.4-1"
#BUNDLED_RUBY_INSTALLER_X64_SHA256SUM = "0c272c995e8247ab7a9db176e84cec46044d15c2cc318d3973def8a410df2b61"
#BUNDLED_RUBY_INSTALLER_X64_VERSION = "3.1.2-1"
#BUNDLED_RUBY_INSTALLER_X64_SHA256SUM = "637039c18dd4ad4a1fed326eed8caca8a686b79cee68bf6b85636bf9ec3a083c"

# Patch files are assumed to be for Ruby's source tree, then applied to
# lib/ruby/x.y.0 in RubyInstaller. So that "-p2" options will be passed
# to patch command.
BUNDLED_RUBY_INSTALLER_PATCHES = [
  ["ruby-3.0/0001-ruby-resolv-Fix-confusion-of-received-response-messa.patch", ["= 2.7.3"]],
  ["ruby-3.0/0001-ruby-resolv-Fix-confusion-of-received-response-messa.patch", ["= 3.0.1"]],
]
