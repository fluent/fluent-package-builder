Profile: fluent-package/main
Extends: debian/main
# * dir-or-file-in-opt
#   As fluent-package is installed under /opt
#
# * custom-library-search-path
#   Known before as binary-or-shlib-defines-rpath.
#   In contrast to Ubuntu, not need to specify old tag
#   because the version of lintian is newer than it.
Disable-Tags: dir-or-file-in-opt,
 custom-library-search-path
