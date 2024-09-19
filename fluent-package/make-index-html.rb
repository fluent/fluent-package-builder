require 'erb'
require 'find'
require 'pathname'
require 'optparse'

options = {
  site: "https://fluentd.cdn.cncf.io",
  verbose: false
}

opt = OptionParser.new
opt.on("-s", "--site URL") { |v| options[:site] = v }
opt.on("-v", "--verbose") { options[:verbose] = true }
top_dir = opt.parse!(ARGV).first

unless File.exist?(top_dir)
  puts "#{top_dir} not found"
  exit 1
end

template_path = File.expand_path("#{File.basename(__FILE__, ".rb")}.erb")
puts "Template path: #{template_path}"
%w(5 lts test).each do |channel|
  search_path = Pathname.new("#{top_dir}/#{channel}")
  Find.find(search_path).each do |path|
    Find.prune unless FileTest.directory?(path)
    Find.prune if path.end_with?("repodata")
    Find.prune if path.end_with?("dists")
    if %w(windows x86_64 aarch64 fluent-package).any? { |dir| path.end_with?(dir) }
      puts "Updating: #{path} ..." if options[:verbose]
      index_path = File.expand_path(File.join(path, "index.html"))
      Dir.chdir(path) do
        files = Dir.glob(["*.deb", "*.msi", "*.rpm"])
        relative_path = Pathname.new(path).relative_path_from(top_dir).to_s
        erb = ERB.new(File.read(template_path)).result(binding)
        File.open(index_path, "w+") do |file|
          file.puts(erb)
          puts "Generated: #{index_path}" if options[:verbose]
        end
      end
    end
  end
end
