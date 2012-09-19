require "rubygems"
require "bundler/setup"

require "net/ping"
require "yaml"

results_file = File.open("results.yml", "a+")
results = {}

test_time = Time.now
results[test_time] = {}
%w(wimdu.co.uk wimdu.com wimdu.de wimdu.it 192.168.1.55).each do |host|
  pinger = Net::Ping::HTTP.new("http://#{host}/") 
  result = pinger.ping? ? "200OK" : pinger.exception
  results[test_time][host] = result
end

results_file << results.to_yaml
