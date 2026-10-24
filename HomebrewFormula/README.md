# Homebrew formula for fluent-package

`HomebrewFormula/fluent-package.rb` installs fluent-package on **Apple
Silicon (arm64) Macs** with Homebrew, as a service-friendly alternative to
the `.dmg` package built by this repository.

```console
$ brew tap fluent/package-builder https://github.com/fluent/fluent-package-builder
$ brew install fluent/package-builder/fluent-package
```

Intel Macs are **not** supported by the formula (`brew install` aborts with
a clear error); use the `.dmg` or build from source for those.

## What you get

| Path (under `brew --prefix`, i.e. `/opt/homebrew`) | Contents |
| --- | --- |
| `bin/fluentd`, `bin/fluent-gem`, `bin/fluent-cat`, `bin/td` | wrapper commands, on your PATH |
| `etc/fluent/fluentd.conf` | configuration; the packaged default never overwrites user edits (standard Homebrew `etc` behaviour): a changed default from a new release arrives as `etc/fluent/fluentd.conf.default` |
| `var/log/fluent/fluentd.log` | log file used by `brew services` |
| `var/fluent/gems/<ruby version>` | where `fluent-gem install` puts user plugins (one directory per Ruby ABI, e.g. `3.4.0`) |
| `var/fluent/gems/<other ruby versions>` | gems from an older pinned Ruby; kept on disk but never loaded (reinstall them with `fluent-gem`) |
| anything else under `var/fluent/gems/` (e.g. `gems/`, `specifications/` directly below it) | layout from before per-ABI namespacing; kept on disk but never loaded (reinstall those plugins with `fluent-gem`) |
| `Cellar/fluent-package/<version>/libexec` | the packaged gems (read-only gem home) |

The Cellar is replaced on every `brew upgrade`, so configuration, logs and
user-installed plugins deliberately live outside it and survive upgrades
(and `brew uninstall`, just like the conffiles of the deb/rpm packages).

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

Plugins go to `var/fluent/gems/<ruby version>` and are found by every
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

* Gems come from the exact gem set that the release's
  `fluent-package/Gemfile.lock` locks; each one is a `resource` block, so
  Homebrew mirrors and checksums every gem file. Windows-only and
  systemd-only gems from that lock are skipped (they cannot even be
  required on macOS: their Gemfile entries are platform-gated).
  The one exception to RubyGems-sourced gems is the `fluentd` gem itself,
  which upstream locks from a git revision: the update script verifies
  (via the GitHub API, cached, dereferencing annotated tags) that the
  locked revision is exactly the commit the release tag points at, and
  aborts if it does not. What that does *not* verify is that the
  published `.gem` the formula installs is content-identical to that
  revision; the gem as published on RubyGems is installed unmodified.
* All fetching happens through Homebrew `resource` blocks before the
  build, and gems install with `gem install --local`, so the build never
  reaches rubygems.org. The cmetrics gem is repacked before install:
  its extconf downloads the C library it compiles from GitHub while the
  native extension builds, which `gem install --local` cannot prevent,
  so the extconf's download URL is repointed at the Homebrew-mirrored
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
  set `GEM_HOME` (to `var/fluent/gems/<ruby version>`) and `GEM_PATH`
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
  it is kept but never loaded (no broken native gems are ever reused).
  If such gems exist, caveats list them on install/upgrade; recover the
  plugins by reinstalling them with `fluent-gem install <gem-name>`.

## Known limitations

* `ffi`, `google-protobuf` and `rdkafka` install as prebuilt
  `arm64-darwin` gem binaries, mirroring the gems upstream locks for its
  own packages. The rdkafka 0.27.0 binary gem embedded by the formula
  carries librdkafka 2.14.0, the version rdkafka 0.27.0 itself targets
  (its `lib/rdkafka/version.rb` pins that source version and sha256 for
  the source builds used elsewhere); the claim that this is byte-identical
  to what the `.dmg` ships is *not* verified. `cmetrics` and the other
  native gems compile from source. A homebrew/core submission
  would instead need a fully from-source gem set linked against
  Homebrew libraries (`librdkafka`, and vendored protobuf/nokogiri
  removal); that changes per-upstream-patch behavior and maintenance
  economics and is deferred (see the update notes below).
* Nokogiri is not installed at all: upstream's Gemfile pins it to Windows
  platforms, and nothing required on macOS uses it.
* `td` is the upstream TD toolbelt CLI gem; it is included for parity
  with the `.dmg` package, not because it is Homebrew-specific.

## Updating the formula for a new release

1. Update `version`, `url` and `sha256` at the top of
   `fluent-package.rb` to the new release tag (the sha256 of
   `https://github.com/fluent/fluent-package-builder/archive/<tag>.tar.gz`).
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
   markers. Keep
   the generated blocks untouched by hand: the CI runs
   `ruby homebrew/update_formula.rb --check`, which fails when a
   newer release tag exists whose lock the formula does not carry.
3. If the release moves to a newer Ruby, update `depends_on "ruby@X.Y"`,
   the `ruby_abi`/`user_gem_dir` helpers and related comments; note that
   all packaged native gems rebuild, and user gems from the old ABI
   directory are intentionally not loaded (caveats say how to recover
   them).
4. Test (see below), then commit both files.

## Testing the formula locally

Inspect the formula through the tap, not through a raw path: a path-based
`brew style`/`audit` checks a second copy alongside the registered tap
and reports duplicate-definition noise.

```console
$ brew tap fluent/package-builder "file://$(pwd)"
$ brew trust fluent/package-builder          # silences the untrusted-tap warnings
$ brew style fluent/package-builder/fluent-package
$ brew audit --strict fluent/package-builder/fluent-package
$ brew install --display-times fluent/package-builder/fluent-package
$ brew test fluent/package-builder/fluent-package
$ HOMEBREW_FORMULA_BUILD_NETWORK=deny \
    brew reinstall fluent/package-builder/fluent-package   # build phase with network blocked
$ brew services start fluent/package-builder/fluent-package && \
  fluent-cat test.hello <<< '{"brew":true}' && \
  grep '"brew":true' "$(brew --prefix)/var/log/fluent/fluentd.log" && \
  brew services stop fluent/package-builder/fluent-package
$ brew untap fluent/package-builder
```

The formula's own `test do` block starts fluentd on a free port, sends a
record with `fluent-cat` and checks that it is echoed to the log, so
`brew test` is a full round trip.

`.github/workflows/homebrew.yml` defines the same checks plus native
extension loading, a user-installed native gem, persistence across
reinstall/uninstall, and a resource freshness check; it is meant to run
on pull requests touching the formula, on a schedule and manually, and
never writes anything to the repository.

**Status:** the workflow has *not executed on GitHub yet* (the branch is
not pushed). What has actually run is the local equivalents (Apple
Silicon, Homebrew 7.0.10): style, audit, a clean install, `brew test`, a
`brew services` round trip, native extension loading, a user-installed
native gem, reinstall/uninstall persistence, and an offline reinstall
with `HOMEBREW_FORMULA_BUILD_NETWORK=deny`. Note that the persistence
check is a `brew reinstall` of the *same* version; a real cross-version
`brew upgrade` cannot be exercised until this tap carries a second
release.
