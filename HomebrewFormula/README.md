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
| `etc/fluent/fluentd.conf` | configuration (a starter config is created only if the file does not exist) |
| `var/log/fluent/fluentd.log` | log file used by `brew services` |
| `var/fluent/gems` | where `fluent-gem install` puts user plugins |
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

Plugins go to `var/fluent/gems` and are found by every fluent command
through `GEM_PATH`. Do not edit the wrapper scripts in `bin/`; they are
replaced on upgrade.

To remove: `brew uninstall fluent/package-builder/fluent-package` leaves
the configuration, logs and user gems in place (delete them by hand to remove everything).

## Formula design

* Gems come from the exact gem set that the release's
  `fluent-package/Gemfile.lock` locks; each one is a `resource` block, so
  Homebrew mirrors and checksums every gem tarball. Windows-only and
  systemd-only gems from that lock are skipped.
* Everything installs into the Cellar with `gem install --local` while the
  build runs offline; the four `bin/` commands are bash wrappers that set
  `GEM_HOME` (to `var/fluent/gems`) and `GEM_PATH` (user gems first, then
  the Cellar).
* The formula depends on Homebrew's `ruby@3.4` instead of bundling a Ruby,
  and native gems build against Homebrew's `openssl@3` through Ruby's
  `rbconfig`. The `@3.4` pin is not cosmetic: the prebuilt `arm64-darwin`
  binary of `google-protobuf` (a fluentd dependency) refuses Ruby 3.5 or
  newer, and 3.4 matches `BUNDLED_RUBY_VERSION` in `fluent-package/config.rb`.
  When a future fluent-package moves to a newer Ruby and its gems support
  it, update the Ruby dependency, rebuild all packaged native gems, and
  migrate or reinstall user gems for the new ABI. Changing the dependency
  alone is insufficient; the current user gem directory is not ABI-isolated.

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
   for arm64 macOS where one exists (e.g. `google-protobuf`) and
   rewrites the block between the `BEGIN/END GENERATED RESOURCE BLOCK`
   markers. Keep the generated blocks untouched by hand: the CI runs
   `ruby homebrew/update_formula.rb --check`, which fails when a
   newer release tag exists whose lock the formula does not carry.
3. Test (see below), then commit both files.

## Testing the formula locally

```console
$ brew tap fluent/package-builder "file://$(pwd)"
$ brew trust fluent/package-builder          # silences the untrusted-tap warnings
$ brew style HomebrewFormula/fluent-package.rb
$ brew audit --strict fluent/package-builder/fluent-package
$ brew install fluent/package-builder/fluent-package
$ brew test fluent/package-builder/fluent-package
$ brew services start fluent/package-builder/fluent-package && \
  fluent-cat test.hello <<< '{"brew":true}' && \
  grep '"brew":true' "$(brew --prefix)/var/log/fluent/fluentd.log" && \
  brew services stop fluent/package-builder/fluent-package
$ brew untap fluent/package-builder
```

The formula's own `test do` block starts fluentd on a free port, sends a
record with `fluent-cat` and checks that it is echoed to the log, so
`brew test` is a full round trip.

`.github/workflows/homebrew.yml` runs all of the above on every pull
request that touches the formula, on a schedule (to catch upstream
releases that make the resources stale), and manually; it never writes
anything to the repository.
