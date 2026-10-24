# Homebrew formula for fluent-package

`HomebrewFormula/fluent-package.rb` installs fluent-package on **Apple
Silicon (arm64) Macs** with Homebrew. It includes launchd integration
through `brew services`.

```console
$ brew tap fluent/package-builder https://github.com/fluent/fluent-package-builder
$ brew install fluent/package-builder/fluent-package
```

Intel Macs are **not** supported by this formula.

## What you get

| Path (under `brew --prefix`, i.e. `/opt/homebrew`) | Contents |
| --- | --- |
| `bin/fluentd`, `bin/fluent-gem`, `bin/fluent-cat`, `bin/td` | wrapper commands, on your PATH |
| `etc/fluent/fluentd.conf` | configuration; the packaged default never overwrites user edits (standard Homebrew `etc` behaviour): a changed default from a new release arrives as `etc/fluent/fluentd.conf.default` |
| `var/log/fluent/fluentd.log` | log file used by `brew services` |
| `var/fluent/gems/<ruby ABI>` | where `fluent-gem install` puts user plugins (one directory per Ruby ABI, e.g. `3.4.0`) |
| `var/fluent/gems/<other Ruby ABIs>` | gems from an older pinned Ruby; kept on disk but never loaded (reinstall them with `fluent-gem`) |
| anything else under `var/fluent/gems/` (e.g. `gems/`, `specifications/` directly below it) | layout from before per-ABI namespacing; kept on disk but never loaded (reinstall those plugins with `fluent-gem`) |
| `Cellar/fluent-package/<version>/libexec` | the packaged gems (managed by Homebrew) |

Homebrew installs each formula version in its own Cellar directory and
may remove older versions during cleanup. Configuration, logs and user
plugins therefore live outside the Cellar. The formula preserves them on
reinstall and uninstall. Plugins from a previous Ruby ABI remain on disk
but must be reinstalled before they can be used with the new ABI.

## Usage

```console
$ brew services start fluent/package-builder/fluent-package   # launchd job, starts at login
$ brew services stop fluent/package-builder/fluent-package
$ brew services restart fluent/package-builder/fluent-package
$ brew services run fluent/package-builder/fluent-package     # run without registering at login
```

`brew services` runs `fluentd -c $(brew --prefix)/etc/fluent/fluentd.conf`
and sends its output to `$(brew --prefix)/var/log/fluent/fluentd.log`.
To run it in the foreground instead: `fluentd -c $(brew --prefix)/etc/fluent/fluentd.conf`.

Install plugins with the wrapped `fluent-gem`, not the system `gem`:

```console
$ fluent-gem install fluent-plugin-s3
$ fluent-gem list
```

Plugins go to `var/fluent/gems/<ruby ABI>` and are found by every
fluent command through `GEM_PATH`. Do not edit the wrapper scripts in
`bin/`; they are replaced on upgrade.

Plugins that are not in the current ABI directory -- because they were
installed before per-ABI namespacing, or for a different Ruby version --
are kept under `var/fluent/gems` but are not loaded. The formula never
moves them; reinstall the ones you need:

```console
$ fluent-gem install fluent-plugin-s3   # repeat for each plugin
```

To remove: `brew uninstall fluent/package-builder/fluent-package` leaves
the configuration, logs and user gems in place (delete them by hand to
remove everything).

## Formula design

* Gem names and versions are generated from the release's
  `fluent-package/Gemfile.lock`, with macOS-inapplicable entries excluded
  by the generator's explicit list. Each included gem has a checksummed
  `resource`; the generator may select a macOS platform variant instead
  of the variant recorded in the lock. This is an adaptation of the
  release dependency set, not a byte-identical copy of another package.
* All gem resources, including `fluentd`, come from RubyGems. For included
  GIT-locked gems, the generator checks that the locked revision matches
  the repository's release tag. It does not compare the published gem's
  contents with that revision. The GitHub API responses are cached.
* All fetching happens through Homebrew `resource` blocks before the
  build, and gems install with `gem install --local`. Build-phase network
  denial was tested locally as described below; the formula does not
  enforce it on every installation. The cmetrics gem is repacked before install:
  its extconf downloads the C library it compiles from GitHub while the
  native extension builds, which `gem install --local` cannot prevent,
  so the extconf's download URL is repointed at the Homebrew-fetched
  `cmetrics-c` resource (a `file://` URL: mini_portile copies it
  locally and verifies the sha256 pinned by the gem itself) and the
  gemspec's `git ls-files` file list is replaced with a glob (outside a
  git checkout that list is empty, which would strip the library and
  extension sources from the repacked gem). Both replacements pin exact
  upstream cmetrics-0.3.3 strings (the extconf's
  `url: "https://codeload.github.com/calyptia/cmetrics/tar.gz/v..."`
  literal and the `spec.files = ...git ls-files...` line); a cmetrics
  bump may require updating them. The offline behaviour was verified by
  building with the network actually blocked: `brew reinstall` under
  Homebrew's standard sandbox with `HOMEBREW_FORMULA_BUILD_NETWORK=deny`
  (note Homebrew 7 allows network in the build phase by default)
  succeeded, while the unpatched cmetrics gem fails under an equivalent
  network block with a connection attempt to codeload.github.com.
* The four `bin/` commands are Homebrew `write_env_script` wrappers that
  set `GEM_HOME` (to `var/fluent/gems/<ruby ABI>`) and `GEM_PATH`
  (user gems first, then the Cellar).
* The formula depends on Homebrew's `ruby@3.4` instead of bundling a Ruby,
  and native gems build against Homebrew's `openssl@3` through Ruby's
  `rbconfig`. The `@3.4` pin is not cosmetic: the prebuilt `arm64-darwin`
  binary of `google-protobuf` (a fluentd dependency) declares
  `required_ruby_version >= 3.1, < 3.5.dev` in its gemspec (checked), so
  it cannot serve Ruby 3.5 or newer, and 3.4 matches
  `BUNDLED_RUBY_VERSION` in `fluent-package/config.rb`.
* User gem directories are per Ruby ABI (`RbConfig::CONFIG["ruby_version"]`,
  e.g. `3.4.0`). Everything else under `var/fluent/gems` -- directories
  of other Ruby ABIs, or the layout from before this namespacing (gems
  installed directly in `var/fluent/gems`) -- is never moved, renamed or
  deleted by the formula, and it stays outside `GEM_HOME`/`GEM_PATH`, so
  it is kept but not selected by these wrappers. This isolates ABI
  directories; it does not establish compatibility with a future Ruby.
  If such gems exist, caveats list them on install/upgrade; recover the
  plugins by reinstalling them with `fluent-gem install <gem-name>`.

## Known limitations

* `ffi`, `google-protobuf` and `rdkafka` use prebuilt `arm64-darwin`
  gems. The formula does not currently build every native dependency
  from source and is not ready for a homebrew/core submission. Source
  builds and use of Homebrew libraries need a separate review.
* The cmetrics repack step depends on upstream source layout and exact
  strings. Review it whenever cmetrics changes; an upstream-supported
  local-source or external-library option would reduce maintenance.
* The published Fluentd gem is not verified to contain exactly the source
  at `FLUENTD_REVISION`. Tag verification alone does not prove this.

Nokogiri is excluded because its upstream Gemfile entry is Windows-only.
The `td` CLI is included as part of the release's plugin and tool set.

## Updating the formula for a new release

1. Update `url` and `sha256` at the top of
   `fluent-package.rb` to the new release tag (the sha256 of
   `https://github.com/fluent/fluent-package-builder/archive/refs/tags/<tag>.tar.gz`).
   The formula version is inferred from the URL.
2. Regenerate the resource blocks from the new tag's `Gemfile.lock`:

   ```console
   $ ruby homebrew/update_formula.rb --tag v6.1.0
   ```

   The script keeps every gem locked by the release (minus the
   macOS-irrelevant ones), resolves the correct `.gem` platform build
   for arm64 macOS where one exists (e.g. `google-protobuf`), verifies
   the `fluentd` git revision against its release tag (locked revision
   == tag's commit; the published `.gem`'s content is not compared), and
   rewrites the block between the `BEGIN/END GENERATED RESOURCE BLOCK`
   markers. Do not edit generated blocks by hand.
   `ruby homebrew/update_formula.rb --check` compares against the newest
   release tag available in the local clone; fetch release tags first.
   In the workflow, this check runs on non-pull-request events only.
3. If the release moves to a newer Ruby, update `depends_on "ruby@X.Y"`,
   the `ruby_abi`/`user_gem_dir` helpers and related comments; note that
   source-built native gems must be rebuilt and prebuilt gems must
   support the new Ruby. User gems from the old ABI
   directory are intentionally not loaded (caveats say how to recover
   them).
4. Review the macOS exclusion list and the cmetrics resource and repack
   code against the new release. Regenerating gem resources does not
   update these automatically.
5. Test (see below), then commit the formula, generated resources and any
   related documentation or workflow changes.

## Testing the formula locally

Use a disposable environment for install, reinstall and uninstall tests.
They change the local Homebrew installation.

Inspect the formula through the tap to avoid checking a second copy of
the same class. A `file://` tap is a separate Git checkout: commit the
changes being tested and ensure the tap checkout contains that commit.
An existing tap is not refreshed by running `brew tap` again.

```console
$ brew tap fluent/package-builder "file://$(pwd)"
$ brew trust fluent/package-builder          # silences the untrusted-tap warnings
$ brew style fluent/package-builder/fluent-package
$ brew audit --strict fluent/package-builder/fluent-package
$ brew install --display-times fluent/package-builder/fluent-package
$ brew test fluent/package-builder/fluent-package
$ HOMEBREW_FORMULA_BUILD_NETWORK=deny \
    brew reinstall fluent/package-builder/fluent-package   # build phase with network blocked
$ brew services start fluent/package-builder/fluent-package
# Wait for Fluentd to start before sending a record.
$ fluent-cat test.hello <<< '{"brew":true}'
# Wait for the record to appear in the log.
$ grep '"brew":true' "$(brew --prefix)/var/log/fluent/fluentd.log"
$ brew services stop fluent/package-builder/fluent-package
```

The formula's own `test do` block starts fluentd on a free port, sends a
record with `fluent-cat` and checks that it is echoed to the log, so
`brew test` is a full round trip.

`.github/workflows/homebrew.yml` defines style, audit, install, `brew test`,
service, native-extension and user-gem checks, plus persistence across
reinstall/uninstall. The build matrix covers macOS 14, 15 and 26. A separate
resource freshness job runs on non-pull-request events. The workflow has
read-only repository permissions.

## Validation status

As of 2026-10-25, the local implementation report records successful
checks on Apple Silicon with Homebrew 7.0.10:

* Style, strict audit, source installation and `brew test`.
* `brew services` start/stop and a record sent with `fluent-cat`.
* Loading the principal native extensions and building a user-installed
  native gem through `fluent-gem`.
* Configuration, user-gem and log preservation across same-version
  reinstall and uninstall.
* Build-phase network denial, including patched/unpatched cmetrics
  comparison tests.
* ABI-directory selection and legacy-layout preservation using fixtures.

These are reported local results, not GitHub Actions results. The workflow
is defined for macOS 14, 15 and 26 but has not been run on GitHub as of
that report. It does not currently enforce build-phase network denial.

The following remain unverified:

* A real upgrade between different formula versions. This can be tested
  in a disposable tap by installing an older formula, updating the tap to
  a newer version, and running `brew upgrade`; a public release is not
  required for a controlled test.
* A real Ruby ABI transition and rebuilding plugins for that new ABI.
* Bottle creation, installation and relocation.
* Published gem contents matching GIT-locked source revisions.
* The freshness check's failure path when a newer release tag is present.
