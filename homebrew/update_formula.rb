# frozen_string_literal: true

# Regenerates the gem `resource` blocks inside fluent-package.rb from the
# Gemfile.lock of a fluent-package release tag.
#
# Usage (run from the repository root):
#
#   ruby homebrew/update_formula.rb --tag v6.0.5
#   ruby homebrew/update_formula.rb --tag v6.0.5 --check
#
# Options:
#   --tag TAG        Release tag whose fluent-package/Gemfile.lock is used
#                    (default: the newest vN.N.N tag).
#   --check          Fail (exit 1) if the formula is not up to date instead
#                    of rewriting it. Intended for CI.
#   --lock FILE      Read the lock from FILE instead of a git tag. For
#                    sandboxed environments or debugging only.
#   --formula FILE   Formula to rewrite (default: the tap formula in
#                    HomebrewFormula/, resolved relative to the repository).
#   --cache DIR      Cache directory for RubyGems API responses
#                    (default: <tmpdir>/fluent-package-formula-cache).
#
# How it works:
#
# 1. Reads the Gemfile.lock of the tag and keeps every locked gem except
#    the ones in EXCLUDED_GEMS below (the macOS formula runs
#    `gem install --ignore-dependencies`, so platform-specific gems that
#    cannot load on macOS are simply left out).
# 2. Asks https://rubygems.org/api/v1/versions/GEM.json for each gem, so
#    prebuilt macOS (.gem platform) builds are used when they exist (for
#    example google-protobuf ships x86_64-darwin and arm64-darwin gems),
#    with the plain ruby build as fallback. The platform sha256 reported
#    by RubyGems is embedded in the formula.
# 3. Replaces the block between the BEGIN/END GENERATED RESOURCE BLOCK
#    markers in the formula.

require "json"
require "net/http"
require "uri"
require "tmpdir"
require "fileutils"
require "open3"

# Gems that the macOS formula does not install. The formula installs gems
# with `gem install --ignore-dependencies` (dependency resolution happens
# in this script, from the lock), so omitting gems that no macOS-flavoured
# fluentd codepath requires is safe, and several of them cannot even be
# built or loaded on macOS.
#
# Windows only (Gemfile platform filter or upstream dependencies):
#   ffi-win32-extensions, nokogiri, rmail, win32-event, win32-eventlog,
#   win32-ipc, win32-service, winevt_c, fluent-plugin-parser-winevt_xml,
#   fluent-plugin-windows-eventlog, fluent-plugin-windows-exporter
# Linux only (Gemfile platform filter):
#   capng_c (needs libcap headers; upstream only supports Linux),
#   fluent-plugin-systemd and systemd-journal (need libsystemd),
#   fluent-plugin-utmpx and linux-utmpx (Linux utmpx)
# Package tooling:
#   bundler (supplied by Homebrew's ruby; not a Fluent Package runtime gem)
EXCLUDED_GEMS = %w[
  capng_c
  certstore_c
  ffi-win32-extensions
  fluent-plugin-parser-winevt_xml
  fluent-plugin-systemd
  fluent-plugin-utmpx
  fluent-plugin-windows-eventlog
  fluent-plugin-windows-exporter
  linux-utmpx
  systemd-journal
  winevt_c
  win32-event
  win32-eventlog
  win32-ipc
  win32-registry
  win32-service
].freeze

# Gems filtered out by upstream platform rules (win32/winevt gems are only
# in the Gemfile under `platforms` filters that never match on macOS, but
# they still appear in the cross-platform lock); they are excluded because
# they either have no darwin gem or are only ever loaded by Windows event
# log plugins.

BEGIN_MARKER = "  # --- BEGIN GENERATED RESOURCE BLOCK ---"
END_MARKER = "  # --- END GENERATED RESOURCE BLOCK ---"

def parse_args
  opts = { tag: nil, check: false, lock: nil, formula: nil, cache: nil }
  args = ARGV.dup
  until args.empty?
    opt, *args = args
    case opt
    when "--tag" then opts[:tag] = args.shift or abort "--tag needs a value"
    when "--check" then opts[:check] = true
    when "--lock" then opts[:lock] = args.shift or abort "--lock needs a value"
    when "--formula" then opts[:formula] = args.shift or abort "--formula needs a value"
    when "--cache" then opts[:cache] = args.shift or abort "--cache needs a value"
    else abort "unknown option: #{opt}"
    end
  end
  opts
end

def script_dir = File.dirname(File.expand_path(__FILE__))

def latest_tag
  tags = `git tag --list 'v[0-9]*'`.split("\n").select { |t| t =~ /\Av\d+\.\d+\.\d+\z/ }
  abort "no release tags found; pass --tag or --lock" if tags.empty?
  tags.sort_by { |t| t.delete("v").split(".").map(&:to_i) }.last
end

def read_lock(opts)
  if opts[:lock]
    File.read(opts[:lock])
  else
    tag = opts[:tag] || latest_tag
    abort "tag #{tag} not found" unless system("git", "rev-parse", "-q", "--verify", "#{tag}^{commit}", out: File::NULL, err: File::NULL)
    warn "reading fluent-package/Gemfile.lock from #{tag}"
    lock, status = Open3.capture2("git", "show", "#{tag}:fluent-package/Gemfile.lock")
    abort "could not read Gemfile.lock from #{tag}" unless status.success?
    lock
  end
end

def specs_from_lock(lock)
  section = lock[/^  specs:\n(.*?)\nPLATFORMS/m, 1]
  abort "could not find specs: section in lock" if section.nil?
  specs = []
  section.each_line do |line|
    next unless (m = line.match(/\A    (\S+) \((\S+)\)/))
    name, version = m[1], m[2]
    next if version =~ /\(/ # sub-dep line like "async (>= 1.10.0)"
    specs << [name, version]
  end
  # Bundler locks cross-platform gems with platform-specific entries such as
  # `google-protobuf (4.32.1-x86_64-linux-gnu)`; normalize to the base
  # version and install the gem flavor that fits macOS.
  specs = specs.sort_by(&:first).uniq
  specs = specs.map do |name, version|
    next [name, version] unless (m = version.match(/\A([\d][\d.]*[A-Za-z0-9.]*?)(?:-(.+))?\z/))
    [name, m[1]]
  end.compact.sort.uniq
  specs
end

def deps_from_lock(lock)
  section = lock[/^  specs:\n(.*?)\nPLATFORMS/m, 1]
  deps = {}
  current = nil
  section.each_line do |line|
    if (m = line.match(/\A    (\S+) /))
      current = m[1]
    elsif (m = line.match(/\A      (\S+)/)) && current
      (deps[current] ||= []) << m[1]
    end
  end
  deps
end

# Gems are installed with `gem install --ignore-dependencies` in the exact
# locked versions, but some gems' native builds invoke other gems at build
# time (digest-crc runs rake, cmetrics requires mini_portile2), so the
# install order must put dependencies before their dependents.
def topo_sort(names, deps)
  remaining = names.sort
  ordered = []
  until remaining.empty?
    ready = remaining.reject { |n| (deps[n] || []).any? { |d| remaining.include?(d) } }
    if ready.empty? # dependency cycle: give up and keep alphabetical order
      ordered.concat(remaining)
      break
    end
    ordered.concat(ready)
    remaining -= ready
  end
  ordered
end

def fetch_json(url, cache_dir)
  slug = url.gsub(%r{[^a-zA-Z0-9]+}, "_")
  cache_path = File.join(cache_dir, "#{slug}.json")
  return JSON.parse(File.read(cache_path)) if File.exist?(cache_path)

  body = +""
  URI.parse(url)
  require "net/http"
  uri = URI.parse(url)
  Net::HTTP.start(uri.host, uri.port, use_ssl: true, max_retries: 3) do |http|
    request = Net::HTTP::Get.new(uri)
    request["User-Agent"] = "fluent-package-builder/update_formula.rb"
    response = http.request(request)
    unless response.is_a?(Net::HTTPSuccess)
      abort "GET #{url} failed: HTTP #{response.code} (no cache at #{cache_path})"
    end
    body = response.body
  end
  File.write(cache_path, body)
  JSON.parse(body)
end

def platform_priority = ["arm64-darwin", "ruby"]

# Returns [download_url, sha256, version, platform] for one gem.
def resolve_gem(cache_dir, name, version)
  meta = fetch_json("https://rubygems.org/api/v1/versions/#{name}.json", cache_dir)
  by_platform = {}
  meta.each do |entry|
    next unless entry["number"] == version
    plat = entry["platform"].to_s
    plat = "ruby" if plat.empty?
    by_platform[plat] ||= [entry["sha"], entry["gem_size"]]
  end

  platform_priority.each do |plat|
    next unless by_platform.key?(plat)
    sha, = by_platform[plat]
    file = plat == "ruby" ? "#{name}-#{version}.gem" : "#{name}-#{version}-#{plat}.gem"
    return ["https://rubygems.org/downloads/#{file}", sha, version, plat]
  end

  [nil, nil, version, nil]
end

def resource_block(name, version, url, sha, platform)
  lines = ["  resource \"#{name}\" do", "    url \"#{url}\"", "    sha256 \"#{sha}\"", "  end"]
  lines.unshift("  # platform: #{platform}") unless platform == "ruby"
  lines.join("\n")
end

def main
  opts = parse_args
  formula_path = opts[:formula] ||
                 File.expand_path("../HomebrewFormula/fluent-package.rb", script_dir)
  cache_dir = opts[:cache] || File.join(Dir.tmpdir, "fluent-package-formula-cache")
  FileUtils.mkdir_p(cache_dir)

  unless opts[:lock]
    opts[:tag] ||= latest_tag
    formula = File.read(formula_path)
    source_tag = formula[%r{archive/refs/tags/(v[^/"\s]+)\.tar\.gz}, 1]
    unless source_tag == opts[:tag]
      abort "formula source tag #{source_tag.inspect} differs from #{opts[:tag]}; update its URL and checksum first"
    end
  end

  lock_text = read_lock(opts)
  specs = specs_from_lock(lock_text).to_h
  warn "#{specs.size} gems in lock"

  included = specs.keys.reject do |name|
    next false unless EXCLUDED_GEMS.include?(name)
    warn "  skip (excluded): #{name} #{specs[name]}"
    true
  end
  order = topo_sort(included, deps_from_lock(lock_text))

  blocks = []
  missing = []
  order.each do |name|
    version = specs.fetch(name)
    url, sha, = resolve_gem(cache_dir, name, version)
    if url.nil?
      missing << "#{name}-#{version}"
      next
    end
    plat = url =~ /-(arm64-darwin|x86_64-darwin)\.gem\z/ ? $1 : "ruby"
    blocks << resource_block(name, version, url, sha, plat)
  end

  abort "no gems resolved from the lock" if blocks.empty?
  unless missing.empty?
    abort "gems not found on rubygems.org for locked versions: #{missing.join(', ')}"
  end

  generated = ([BEGIN_MARKER,
                "  # Generated by homebrew/update_formula.rb -- DO NOT EDIT",
                "  # Source: Gemfile.lock of #{opts[:tag] || opts[:lock] || latest_tag}",
                "  # #{specs.size} locked gems; #{EXCLUDED_GEMS.size} platform-specific gems excluded.",
                *blocks].join("\n")) + "\n" + END_MARKER + "\n"

  formula = File.read(formula_path)
  unless formula.include?(BEGIN_MARKER) && formula.include?(END_MARKER)
    abort "markers #{BEGIN_MARKER.inspect}/#{END_MARKER.inspect} not found in #{formula_path}"
  end
  updated = formula.sub(/#{Regexp.escape(BEGIN_MARKER)}\n.*?#{Regexp.escape(END_MARKER)}\n/m) { generated }

  if updated == formula
    warn "formula resources are up to date"
    exit 0
  end

  if opts[:check]
    warn "resource blocks are out of date (rerun without --check)"
    exit 1
  end

  File.write(formula_path, updated)
  warn "wrote #{blocks.size} resource blocks to #{formula_path}"
end

main
