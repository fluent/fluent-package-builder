#
# Utility to update fluent-package-builder/fluent-package/Gemfile
#

require 'optparse'
require 'open-uri'
require 'json'
require 'fileutils'
begin
  require 'pastel'
rescue LoadError
  puts "Prerequisite:\n\tgem install pastel"
  exit 1
end

options = {
  lts: false,
  replace: true,
  gemfile: "Gemfile"
}

class GemfileUpdateChecker
  def initialize(options)
    @options = options
    @gemfile_path = options[:gemfile]
    @new_gemfile_path = @gemfile_path + ".new"
    @pastel = Pastel.new
    @freeze_in_lts = %w(oj)
  end

  def fetch_latest_version(gem, version)
    base_version = version.split(".")[0..-2].join(".")
    latest_version = version
    message = ""
    URI.open("https://rubygems.org/api/v1/gems/#{gem}.json") do |request|
      fetched_version = JSON.parse(request.read)["version"]
      if @options[:lts]
        if Gem::Version.new(fetched_version) < Gem::Version.new("#{base_version.succ}")
          if @freeze_in_lts.include?(gem)
            message = @pastel.red.on_black ( "WARN: skip even though teeny update #{gem} #{fetched_version} for LTS" )
          else
            latest_version = fetched_version
          end
        else
          message = @pastel.yellow.on_black ( "WARN: skip #{gem} #{fetched_version} for LTS" )
        end
      else
        latest_version = fetched_version
      end
    end
    [latest_version, message]
  end

  def show_latest_version(gem, version, latest_version, appendix = "")
    if version != latest_version
      puts "GEM: #{gem} #{version} => #{@pastel.magenta.on_black( latest_version )} #{appendix}"
    else
      puts "GEM: #{gem} #{latest_version} #{appendix}"
    end
  end

  def generate_updated_gemfile
    contents = ""
    File.open(@gemfile_path, "r") do |gemfile|
      gemfile.readlines.each do |line|
        if line.start_with?("gem")
          if line =~ /^gem "(.+)", "(.+)"(.*)/
            plugin=$1
            version=$2
            rest=$3
            latest_version, warning = fetch_latest_version(plugin, version)
            show_latest_version(plugin, version, latest_version, warning)
            contents << "gem \"#{plugin}\", \"#{latest_version}\"#{rest}\n"
          elsif line =~ /^gem "(.+)", '(.+)'/
            plugin=$1
            version=$2
            latest_version, warning = fetch_latest_version(plugin, version)
            show_latest_version(plugin, version, latest_version, warning)
            contents << "gem \"#{plugin}\", \"#{latest_version}\"\n"
          else
            contents << line
          end
        else
          contents << line
        end
      end
    end
    contents
  end

  def run
    File.open(@new_gemfile_path, "w+") do |gemfile|
      contents = generate_updated_gemfile
      gemfile.puts(contents)
      puts "#{@new_gemfile_path} was generated successfully"
    end
    if @options[:replace]
      FileUtils.cp(@new_gemfile_path, @gemfile_path)
      puts "#{@gemfile_path} was replaced with #{@new_gemfile_path} successfully"
    else
      puts "#{@gemfile_path} was not replaced with #{@new_gemfile_path}"
    end
  end
end
