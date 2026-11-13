# Homebrew formula for fluent-package

`homebrew/Formula/fluent-package.rb` installs fluent-package on **Apple
Silicon (arm64) Macs** with Homebrew. It includes launchd integration
through `brew services`.

```console
$ brew tap fluent/package-builder https://github.com/fluent/fluent-package-builder
$ brew install fluent/package-builder/fluent-package
```

Homebrew only discovers formulae under a top-level `Formula/` (or legacy
`HomebrewFormula/`) directory of a tap repository, so the repository's
top-level `Formula` entry is a symlink to this directory's `Formula/`;
keep it if files are moved around.

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

* The generator reads the release's `fluent-package/Gemfile.lock`, excludes
  gems that do not apply to macOS, and can select prebuilt arm64 macOS gems.
  Homebrew fetches the checksummed resources before installation.
* For gems locked to Git revisions, the generator checks that the release
  tag points to the locked commit. It does not compare the contents of the
  published gem with that commit. If the cached RubyGems metadata lacks a
  locked version, the generator fetches fresh metadata.
* The formula repacks cmetrics so its native extension can use a C library
  archive fetched by Homebrew. Review the patch and the archive resource
  whenever cmetrics changes.
* The formula uses Homebrew's Ruby and OpenSSL. Keep the Ruby series
  aligned with the one bundled by Fluent Package. If the Ruby ABI
  changes, reinstall user plugins with `fluent-gem`.
* A submission to `homebrew/core` would need a separate review of prebuilt
  gems and native library dependencies.

## Updating the formula for a new release

1. Update `url` and `sha256` at the top of
   `homebrew/Formula/fluent-package.rb` to the new release tag (the sha256 of
   `https://github.com/fluent/fluent-package-builder/archive/refs/tags/<tag>.tar.gz`).
   The formula version is inferred from the URL.
2. Regenerate the resource blocks from the new tag's `Gemfile.lock`.
   Replace `<release-tag>` with the tag used in step 1:

   ```console
   $ ruby homebrew/update_formula.rb --tag <release-tag>
   ```

   The script rewrites the generated resource block. Do not edit that
   block by hand. To check the formula against the newest release tag in
   the local clone, fetch the release tags and run
   `ruby homebrew/update_formula.rb --check`.
3. If the release changes Ruby series, review the formula's Ruby and
   OpenSSL dependencies, the Ruby commands used during installation, and
   compatibility with prebuilt gems. If the Ruby ABI changes, native
   extensions built from source must be rebuilt.
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
