# TODO about fluent-package-builder

## Enable lintian check on Ubuntu Focal (Arm64)

See https://github.com/fluent-plugins-nursery/fluent-package-builder/issues/65

Because of stucking lintian process, we can't enable
lintian check on Ubuntu Focal (Arm64) and Groovy.

The reason why lintian process stalls is caused by IO::Async and
that dependency was removed since lintian 2.92.0 [1], so we can
remove this workaround from Ubuntu Hirsute (21.04) or later.

[1] https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=964770
