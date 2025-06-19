Profile: fluent-package/main
Extends: ubuntu/main
# * dir-or-file-in-opt
#   As fluent-package is installed under /opt
#
# * binary-or-shlib-defines-rpath,
#   To work expectedly both of focal or later version,
#   the old tag name of custom-library-search-path
#   (binary-or-shlib-defines-rpath) must be specified.
#
Disable-Tags: dir-or-file-in-opt
 binary-or-shlib-defines-rpath
