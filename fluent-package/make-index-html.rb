require 'erb'
require 'find'
require 'pathname'
require 'optparse'

options = {
  site: "https://fluentd.cdn.cncf.io",
  verbose: false,
  channel: "5,lts,test"
}

opt = OptionParser.new
opt.on("-s", "--site URL", "Specify distribution site (e.g. https://fluentd.cdn.cncf.io)") { |v| options[:site] = v }
opt.on("-v", "--verbose", "Enable verbose logging") { options[:verbose] = true }
opt.on("-c", "--channel TARGET_CHANNEL", "Specify channel with comma separated (e.g. --channel 5,lts)") { |v| options[:channel] = v }
top_dir = opt.parse!(ARGV).first

unless File.exist?(top_dir)
  puts "#{top_dir} not found"
  exit 1
end

template_path = File.expand_path("#{File.dirname(__FILE__)}/#{File.basename(__FILE__, '.rb')}.erb")
puts "Template path: #{template_path}"
Find.find("#{top_dir}/#{options[:channel]}") do |path|
  Find.prune if File.file?(path)
  puts "Updating: #{path} ..." if options[:verbose]
  index_path = File.expand_path(File.join(path, "index.html"))
  Dir.chdir(path) do
    files = Dir.glob("*")
    relative_path = Pathname.new(path).relative_path_from(top_dir).to_s
    erb = ERB.new(File.read(template_path)).result(binding)
    File.open(index_path, "w+") do |file|
      file.puts(erb)
      puts "Generated: #{index_path}" if options[:verbose]
    end
  end
end
