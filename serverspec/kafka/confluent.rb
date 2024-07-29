require_relative "../spec_helper"
require "rdkafka"

if ["redhat", "amazon"].include?(os[:family])
describe "rdkafka" do
  it "can receive message via Rdkafka client" do
    config = {
      "bootstrap.servers": "localhost:9092",
      "group.id": "test"
    }
    consumer = Rdkafka::Config.new(config).consumer
    consumer.subscribe("test")

    wait_for_consumer_assignment(consumer)

    `echo "Hello, rdkafka" | /usr/bin/kafka-console-producer --broker-list localhost:9092 --topic test`

    message = consumer.each { |message| break message }
    expect(message.payload).to eq "Hello, rdkafka"
  end
end

describe "fluent-plugin-kafka" do
  it "can receive message via fluent-plugin-kafka" do
    `echo "Hello, fluent-plugin-kafka" | /usr/bin/kafka-console-producer --broker-list localhost:9092 --topic test`
    Dir.glob("/tmp/log/td-agent/*.log") do |path|
      File.open(path) do |file|
        expect(JSON.parse(file.readlines.last)["message"]).to eq "Hello, fluent-plugin-kafka"
      end
    end
  end
end
end
