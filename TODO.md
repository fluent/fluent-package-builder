# TODO about td-agent-builder

## Enable Travis-CI

See https://github.com/fluent-plugins-nursery/td-agent-builder/issues/153

Because of conflicting dependency tzinfo, we can't enable
Travis-CI.

When activesupport 6.1 has been released, we can enable it again.
To enable it, uncomment `.travis.yml`.

## Enable lintian check on Ubuntu Focal (Arm64)

See https://github.com/fluent-plugins-nursery/td-agent-builder/issues/65

Because of stucking lintian process, we can't enable
lintian check on Ubuntu Focal (Arm64).

The reason why lintian process stalls is not known, so
we disable it by setting LINTIAN=no on `.travis.yml`

To enable it, remove `LINTIAN=no` from `.travis.yml`.
