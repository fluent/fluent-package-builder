require_relative 'package-task'
require 'rake/clean'

class TDAgentPackageTask < PackageTask
  def initialize(package_name, version)
    super(package_name, version, detect_release_time)
    @archive_tar_name = "#{package_name}-#{version}.tar"
    @archive_name = "#{@archive_tar_name}.gz"
    CLEAN.include(@archive_name)
  end

  private

  def define_archive_task
    file @archive_name do
      build_archive
    end
  end

  def build_archive
    cd ".." do
      sh("git", "archive", "HEAD",
         "--prefix", "#{@archive_base_name}/",
         "--output", @full_archive_name)
    end
  end

  def apt_targets_default
    [
      "debian-buster",
      "ubuntu-bionic",
    ]
  end

  def yum_targets_default
    [
      "centos-7",
      "centos-8",
    ]
  end

  private
  def detect_release_time
    release_time_env = ENV["TD_AGENT_RELEASE_TIME"]
    if release_time_env
      Time.parse(release_time_env).utc
    else
      Time.now.utc
    end
  end
end
