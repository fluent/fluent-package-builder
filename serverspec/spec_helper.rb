require "serverspec"

set :backend, :exec

def wait_for_consumer_assignment(consumer)
  10.times do
    break if !consumer.assignment.empty?
    sleep 1
  end
end

def centos8?(os)
  os[:family] == "redhat" and os[:release].split(".", 2)[0].to_i >= 8
end
