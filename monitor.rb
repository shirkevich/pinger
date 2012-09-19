require "rubygems"
require "bundler/setup"

require "listen"
require 'net/smtp'

def email_webmaster(error_time, hosts_with_errors)
  text = "Dear webmaster, following hosts were timeouted: #{hosts_with_errors.inspect} at #{error_time}"
message = <<MESSAGE_END
From: ping_robot <robot@wimdu.com>
To: Webmaster <webmaster@wimdu.com>
Subject: ping errors
#{text}
MESSAGE_END
  Net::SMTP.start('localhost') do |smtp|
    smtp.send_message message, 'robot@wimdu.com', 
  end
end

def check_last_ping
  log = File.open('results.yml')
  hosts_with_errors = [] 
  ping_time = ''
  result = YAML::load_documents(log)[-1]
  result.each do |time, hosts|
    ping_time = time
    hosts.each do |host, result|
      hosts_with_errors << host unless result == '200OK'
    end
  end
  
  email_webmaster(ping_time, hosts_with_errors) unless hosts_with_errors.empty?
end

Listen.to('./', filter: /results\.yml$/) do |modified, added, removed|  
  check_last_ping
end
