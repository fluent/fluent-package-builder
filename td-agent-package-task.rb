require_relative "./lib/apache-arrow-src/dev/tasks/linux-packages/package-task"

class TDAgentPackageTask < PackageTask
  def initialize(version)
    super("td-agent", version, detect_release_time)
    @archive_name = "td-agent-#{version}.tar.gz"
    @original_archive_name = @archive_name
  end

  private
  def define_archive_task
    build_archive
  end

  def build_archive
    sh("git", "archive", "HEAD",
       "--prefix", "#{@archive_base_name}/",
       "--output", @full_archive_name)
  end

  def apt_targets_default
    [
      "debian-stretch",
      "debian-stretch-i386",
      "debian-buster",
      "debian-buster-i386",
    ]
  end

  def yum_targets_default
    [
      "centos-6",
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
