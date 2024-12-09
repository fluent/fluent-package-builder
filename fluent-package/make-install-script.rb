require 'erb'
require 'pathname'
require 'optparse'
require 'open-uri'

#
# This script generate our install script and replaces the install
# script which was hosted on https://toolbelt.treasuredata.com/ previously.
#

options = {
  site: "https://fluentd.cdn.cncf.io",
  channel: %w(4 5),
  verify: false,
  debug: false
}

opt = OptionParser.new
opt.on("-a", "--archive", "Enable archived installed script to verify with") { |v| options[:archive] = true }
opt.on("-b", "--backup", "Backup original install script (e.g. https://toolbelt.treasuredata.com)") { |v| options[:backup] = true }
opt.on("-c", "--channel TARGET_CHANNEL", Array, "Specify channel with comma separated (e.g. --channel 4,5)") { |v| options[:channel] = v }
opt.on("-d", "--debug", "Enable debug logging") { options[:debug] = true }
opt.on("-s", "--site URL", "Specify distribution site (e.g. https://fluentd.cdn.cncf.io)") { |v| options[:site] = v }
opt.on("-v", "--verify", "Enable verification mode") { options[:verify] = true }
top_dir = opt.parse!(ARGV).first

unless File.exist?(top_dir)
  puts "#{top_dir} not found"
  exit 1
end

class FluentInstallScript
  def initialize(options={})
    @options = options
    @package_name = 'fluent-package'
    @old_package_name = 'td-agent'
    @repo_file = 'fluent-package.repo'
    @old_repo_file = 'td.repo'
    @lts_repo_file = 'fluent-package-lts.repo'
    @base_url = options[:site]
    @metadata = {}
    @template_path = File.expand_path("#{File.basename(__FILE__, ".rb")}.erb")
    @archive_dir = File.expand_path(File.join(File.dirname(__FILE__), "toolbelt"))
  end

  def relative_install_script(symbol)
    script_base = symbol.to_s.gsub(/_/, '-')
                    .sub(/agent25/, 'agent2.5')
    "sh/#{script_base}.sh"
  end

  def setup_metadata
    @options[:channel].each do |channel|
      case channel
      when "5"
        @metadata.merge!(generate_5x_metadata)
      when "4"
        @metadata.merge!(generate_4x_metadata)
      when "3"
        @metadata.merge!(generate_3x_metadata)
      when "2.5"
        @metadata.merge!(generate_25x_metadata)
      when "2"
        @metadata.merge!(generate_2x_metadata)
      when "1"
        @metadata.merge!(generate_1x_metadata)
      end
    end
  end

  def backup_install_scripts
    setup_metadata
    @metadata.keys.each do |key|
      install_script_path = relative_install_script(key)
      previous_script_url = "https://toolbelt.treasuredata.com/#{install_script_path}"
      puts "Fetch: #{previous_script_url}" if @options[:debug]
      previous_content = URI.open(previous_script_url) { |f| f.read }
      backup_script_path = File.expand_path(File.join(@archive_dir, File.basename(install_script_path)))
      FileUtils.mkdir_p(@archive_dir)
      File.open(backup_script_path, "w+") do |file|
        file.puts(previous_content)
        puts "Generated: #{backup_script_path}" if @options[:debug]
      end
    end
  end

  def previous_script_uri(install_script)
    if @options[:archive]
      File.expand_path(@archive_dir, File.basename(install_script))
    else
      "https://toolbelt.treasuredata.com/#{install_script}"
    end
  end

  def fetch_previous_install_script(install_script)
    if @options[:archive]
      install_script_path = File.expand_path(File.join(@archive_dir, File.basename(install_script)))
      puts "Read: #{install_script_path}" if @options[:debug]
      content = File.open(install_script_path) { |f| f.read }
    else
      previous_script_url = "https://toolbelt.treasuredata.com/#{install_script}"
      puts "Fetch: #{previous_script_url}" if @options[:debug]
      content = URI.open(previous_script_url) { |f| f.read }
    end
    # reinterpret for newer hosting site
    content.gsub(/packages.treasuredata.com/, 'fluentd.cdn.cncf.io')
      .gsub(/http:/, 'https:')
  end

  def generate_install_scripts(top_dir)
    setup_metadata
    puts "Template path: #{@template_path}" if @options[:debug]
    @metadata.keys.each do |key|
      install_script_path = File.join(top_dir, relative_install_script(key))
      install_info = @metadata[key]
      content = ERB.new(File.read(@template_path), trim_mode: '<>').result(binding)
      File.open(install_script_path, "w+") do |file|
        file.puts(content)
        puts "Generated: #{install_script_path}"
      end
      if @options[:verify]
        previous_content = fetch_previous_install_script(relative_install_script(key))
        previous_script_path = previous_script_uri(relative_install_script(key))
        if previous_content != content # ignore newline
          if @options[:debug]
            File.open("/tmp/before.txt", "w+") { |f| f.write(previous_content) }
            File.open("/tmp/after.txt", "w+") { |f| f.write(content) }
            puts `diff -u /tmp/before.txt /tmp/after.txt`
          end
          puts "[NG] Compared with: #{previous_script_path}"
        else
          puts "[OK] Compared with: #{previous_script_path}"
        end
      end
    end
  end
  
  def generate_5x_metadata
    metadata = {}
    puts "Processing fluent-package 5 ..." if @options[:debug]
    template = {
      channel_version: 5,
      package_name: @package_name,
      base_url: @base_url
    }
    rhel_template = template.merge({
                                     channel_version: 5,
                                     distribution: 'redhat',
                                     repo_label: @package_name,
                                     repo_file: @repo_file,
                                     repo_name: 'Fluentd Project',
                                   })
    rhel_lts_template = rhel_template.merge({
                                              repo_file: @lts_repo_file,
                                              repo_label: "#{@package_name}-lts",
                                              lts: true
                                            })
    debian_template = template.merge({
                                       distribution: 'debian',
                                       apt_source_deb: 'fluent-apt-source/fluent-apt-source_2023.6.29-1_all.deb',
                                       apt: 'apt'
                                     })
    ubuntu_template = debian_template.merge({
                                              distribution: 'ubuntu',
                                              apt_source_deb: 'fluent-apt-source/fluent-apt-source_2023.6.29-1_all.deb'
                                            })
    debian_lts_template = debian_template.merge({
                                                  apt_source_deb: 'fluent-lts-apt-source/fluent-lts-apt-source_2023.7.29-1_all.deb',
                                                  lts: true
                                                })
    ubuntu_lts_template = ubuntu_template.merge({
                                                  apt_source_deb: 'fluent-lts-apt-source/fluent-lts-apt-source_2023.7.29-1_all.deb',
                                                  lts: true
                                                })
    metadata.merge!({
                      install_redhat_fluent_package5: rhel_template,
                      install_amazon2_fluent_package5: rhel_template.merge({distribution: 'amazon', version: 2}),
                      install_amazon2023_fluent_package5: rhel_template.merge({distribution: 'amazon', version: 2023}),
                      install_ubuntu_noble_fluent_package5: ubuntu_template.merge({version: 'noble'}),
                      install_ubuntu_jammy_fluent_package5: ubuntu_template.merge({version: 'jammy'}),
                      install_ubuntu_focal_fluent_package5: ubuntu_template.merge({version: 'focal'}),
                      install_debian_bullseye_fluent_package5: debian_template.merge({version: 'bullseye'}),
                      install_debian_bookworm_fluent_package5: debian_template.merge({version: 'bookworm'}),
                      install_redhat_fluent_package5_lts: rhel_lts_template,
                      install_amazon2_fluent_package5_lts: rhel_lts_template.merge({distribution: 'amazon', version: 2}),
                      install_amazon2023_fluent_package5_lts: rhel_lts_template.merge({distribution: 'amazon', version: 2023}),
                      install_ubuntu_noble_fluent_package5_lts: ubuntu_lts_template.merge({version: 'noble'}),
                      install_ubuntu_jammy_fluent_package5_lts: ubuntu_lts_template.merge({version: 'jammy'}),
                      install_ubuntu_focal_fluent_package5_lts: ubuntu_lts_template.merge({version: 'focal'}),
                      install_debian_bullseye_fluent_package5_lts: debian_lts_template.merge({version: 'bullseye'}),
                      install_debian_bookworm_fluent_package5_lts: debian_lts_template.merge({version: 'bookworm'}),
                    })
  end

  def generate_4x_metadata
    metadata = {}
    template = {
      channel_version: 4,
      package_name: @old_package_name,
      base_url: @base_url
    }
    rhel_template = template.merge({
                                     distribution: 'redhat',
                                     repo_file: @old_repo_file,
                                     repo_label: 'treasuredata',
                                     repo_name: 'TreasureData',
                                   })
    debian_template = template.merge({
                                       repo_label: 'treasuredata',
                                       distribution: 'debian',
                                       apt_source_deb: 'fluentd-apt-source/fluentd-apt-source_2020.8.25-1_all.deb',
                                       apt: 'apt'
                                     })
    ubuntu_template = debian_template.merge({
                                              distribution: 'ubuntu',
                                              apt_source_deb: 'fluentd-apt-source/fluentd-apt-source_2020.8.25-1_all.deb'
                                            })
    metadata.merge!({
                      install_redhat_td_agent4: rhel_template,
                      install_amazon2_td_agent4: rhel_template.merge({distribution: 'amazon', version: 2}),
                      install_ubuntu_jammy_td_agent4: ubuntu_template.merge({version: 'jammy'}),
                      install_ubuntu_focal_td_agent4: ubuntu_template.merge({version: 'focal'}),
                      install_ubuntu_bionic_td_agent4: ubuntu_template.merge({version: 'bionic'}),
                      install_ubuntu_xenial_td_agent4: ubuntu_template.merge({version: 'xenial'}),
                      install_debian_bullseye_td_agent4: debian_template.merge({version: 'bullseye'}),
                      install_debian_buster_td_agent4: debian_template.merge({version: 'buster'}),
                    })
  end

  def generate_3x_metadata
    metadata = {}
    template = {
      channel_version: 3,
      package_name: @old_package_name,
      base_url: @base_url
    }
    rhel_template = template.merge({
                                     distribution: 'redhat',
                                     repo_file: @old_repo_file,
                                     repo_label: 'treasuredata',
                                     repo_name: 'TreasureData',
                                   })
    debian_template = template.merge({
                                       repo_label: 'treasuredata',
                                       distribution: 'debian',
                                       apt_source_deb: 'fluentd-apt-source/fluentd-apt-source_2020.8.25-1_all.deb',
                                       apt: 'apt-get'
                                     })
    ubuntu_template = template.merge({
                                       distribution: 'ubuntu',
                                       apt_source_deb: 'fluentd-apt-source/fluentd-apt-source_2020.8.25-1_all.deb',
                                       apt: 'apt-get'
                                     })
    metadata.merge!({
                      install_redhat_td_agent3: rhel_template,
                      install_amazon1_td_agent3: rhel_template.merge({distribution: 'amazon', version: 1}),
                      install_amazon2_td_agent3: rhel_template.merge({distribution: 'amazon', version: 2}),
                      install_ubuntu_bionic_td_agent3: ubuntu_template.merge({version: 'bionic'}),
                      install_ubuntu_xenial_td_agent3: ubuntu_template.merge({version: 'xenial'}),
                      install_ubuntu_trusty_td_agent3: ubuntu_template.merge({version: 'trusty'}),
                      install_debian_buster_td_agent3: debian_template.merge({version: 'buster'}),
                      install_debian_stretch_td_agent3: debian_template.merge({version: 'stretch'}),
                      install_debian_jessie_td_agent3: debian_template.merge({version: 'jessie'}),
                    })
  end

  def generate_25x_metadata
    metadata = {}
    template = {
      channel_version: 2.5,
      package_name: @old_package_name,
      base_url: @base_url
    }
    rhel_template = template.merge({
                                     distribution: 'redhat',
                                     repo_file: @old_repo_file,
                                     repo_label: 'treasuredata',
                                     repo_name: 'TreasureData',
                                   })
    debian_template = template.merge({
                                       repo_label: 'treasuredata',
                                       distribution: 'debian',
                                       apt_source_deb: 'fluentd-apt-source/fluentd-apt-source_2020.8.25-1_all.deb',
                                       apt: 'apt-get'
                                     })
    ubuntu_template = debian_template.merge({
                                              distribution: 'ubuntu',
                                              apt_source_deb: 'fluentd-apt-source/fluentd-apt-source_2020.8.25-1_all.deb',
                                            })
    metadata.merge!({
                      install_redhat_td_agent25: rhel_template,
                      install_ubuntu_bionic_td_agent25: ubuntu_template.merge({version: 'bionic'}),
                      install_ubuntu_xenial_td_agent25: ubuntu_template.merge({version: 'xenial'}),
                      install_ubuntu_trusty_td_agent25: ubuntu_template.merge({version: 'trusty'}),
                      install_debian_stretch_td_agent25: debian_template.merge({version: 'stretch'}),
                    })
  end

  def generate_2x_metadata
    metadata = {}
    template = {
      channel_version: 2,
      package_name: @old_package_name,
      base_url: @base_url
    }
    rhel_template = template.merge({
                                     distribution: 'redhat',
                                     repo_file: @old_repo_file,
                                     repo_label: 'treasuredata',
                                     repo_name: 'TreasureData',
                                   })
    debian_template = template.merge({
                                       repo_label: 'treasuredata',
                                       distribution: 'debian',
                                       apt_source_deb: 'fluentd-apt-source/fluentd-apt-source_2020.8.25-1_all.deb',
                                       apt: 'apt-get'
                                     })
    ubuntu_template = debian_template.merge({
                                              distribution: 'ubuntu',
                                              apt_source_deb: 'fluentd-apt-source/fluentd-apt-source_2020.8.25-1_all.deb',
                                            })
    metadata.merge!({
                      install_redhat5_td_agent2: rhel_template.merge({old_sha1: true}),
                      install_redhat_td_agent2: rhel_template,
                      install_ubuntu_xenial_td_agent2: ubuntu_template.merge({version: 'xenial'}),
                      install_ubuntu_trusty_td_agent2: ubuntu_template.merge({version: 'trusty'}),
                      install_ubuntu_precise_td_agent2: ubuntu_template.merge({version: 'precise'}),
                      install_ubuntu_lucid_td_agent2: ubuntu_template.merge({version: 'lucid'}),
                      install_debian_stretch_td_agent2: debian_template.merge({version: 'stretch'}),
                      install_debian_jessie_td_agent2: debian_template.merge({version: 'jessie'}),
                      install_debian_wheezy_td_agent2: debian_template.merge({version: 'wheezy'}),
                      install_debian_squeeze_td_agent2: debian_template.merge({version: 'squeeze'}),
                    })
  end

  def generate_1x_metadata
    metadata = {}
    template = {
      channel_version: 1,
      package_name: @old_package_name,
      base_url: @base_url
    }
    rhel_template = template.merge({
                                     distribution: 'redhat',
                                     repo_file: @old_repo_file,
                                     repo_label: 'treasuredata',
                                     repo_name: 'TreasureData',
                                     old_sha1: true
                                   })
    debian_template = template.merge({
                                       repo_label: 'treasuredata',
                                       distribution: 'debian',
                                       apt: 'apt-get'
                                     })
    ubuntu_template = debian_template.merge({
                                              distribution: 'ubuntu'
                                            })
    metadata.merge!({
                      install_redhat: rhel_template,
                      install_ubuntu_precise: ubuntu_template.merge({version: 'precise'}),
                      # lucid should be /lucid, but kept under /debian
                      install_ubuntu_lucid: debian_template.merge({version: 'lucid'}),
                      install_debian_lenny: ubuntu_template.merge({version: 'lenny'}),
                    })
  end

  def run(top_dir)
    if @options[:backup]
      backup_install_scripts
    else
      generate_install_scripts(top_dir)
    end
  end
end

runner = FluentInstallScript.new(options)
runner.run(top_dir)
