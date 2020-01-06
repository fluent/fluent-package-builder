require_relative "./lib/apache-arrow-src/dev/tasks/linux-packages/package-task"

class TDAgentPackageTask < PackageTask
  def initialize(version)
    super("td-agent", version, detect_release_time)
    @archive_tar_name = "td-agent-#{version}.tar"
    @archive_name = "#{@archive_tar_name}.gz"
    @original_archive_name = @archive_name
  end

  def dist
    define_dist_task
  end

  def define
    define_apt_task
    define_yum_task
    define_version_task
  end

  private

  def define_dist_task
    define_archive_task
    desc "Create release package"
    task :dist
  end

  def define_archive_task
    build_archive
  end

  def build_archive
    sh("git", "archive", "HEAD",
       "--prefix", "#{@archive_base_name}/",
       "--output", @full_archive_name)
    sh("gunzip", @full_archive_name)
    sh("tar", "rf",
       @archive_tar_name,
       File.join("lib", "apache-arrow-src", "dev", "tasks", "linux-packages", "package-task.rb"),
       "--transform", "s,^lib,#{@archive_base_name}/lib,")
    sh("gzip", @archive_tar_name)
  end

  def apt_targets_default
    [
      "debian-buster",
      "debian-buster-i386",
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
