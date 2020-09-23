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

## Remove find_installed_gem.ps1 from serverspec

See https://github.com/mizzy/specinfra/pull/721

Because of invalid logic to detect gem on Windows, we still
need to use modified version of `FindInstalledGem`.

When #721 is merged, we can remove `serverspec/find_installed_gem.ps1`
and stop to override in `td-agent/msi/serverspec-test.ps1`.
