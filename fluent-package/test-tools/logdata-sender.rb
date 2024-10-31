require "socket"
require "syslog"
require "optparse"

udp_data_count = 50
tcp_data_count = 60
syslog_data_count = 70
syslog_identifer = "test-syslog"
output_duration_sec = 4.0

opt = OptionParser.new
opt.on("--udp-data-count num") { |v| udp_data_count = v.to_i }
opt.on("--tcp-data-count num") { |v| tcp_data_count = v.to_i }
opt.on("--syslog-data-count num") { |v| syslog_data_count = v.to_i }
opt.on("--syslog-identifer name") { |v| syslog_identifer = v }
opt.on("--duration num") { |v| output_duration_sec = v.to_f }
opt.parse!(ARGV)

threads = []

## UDP
threads << Thread.new do
  i = 0
  begin
    s = UDPSocket.open
    s.connect("localhost", 5170)

    loop do
      break if i == udp_data_count
      s.puts "[udp][#{i}] hello"
      i += 1
      sleep (output_duration_sec / udp_data_count)
    end
  rescue Errno::ECONNRESET, Errno::ECONNREFUSED
    retry
  end
ensure
  s.close
end

## TCP
threads << Thread.new do
  i = 0
  begin
    s = TCPSocket.open("localhost", 5170)

    loop do
      break if i == tcp_data_count
      s.puts "[tcp][#{i}] hello"
      i += 1
      sleep (output_duration_sec / tcp_data_count)
    end
  rescue Errno::ECONNRESET, Errno::ECONNREFUSED
    retry
  end
ensure
  s.close
end

## Syslog
threads << Thread.new do
  Syslog.open(syslog_identifer)
  i = 0
  loop do
    break if i == syslog_data_count
    Syslog.info("[syslog][#{i}] hello")
    i += 1
    sleep (output_duration_sec / syslog_data_count)
  end
ensure
  Syslog.close
end

threads.each(&:join)
