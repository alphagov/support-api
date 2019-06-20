require 'zendesk_api'

@client = ZendeskAPI::Client.new do |config|
  config.url = ENV['ZENDESK_URL']
  config.username = ENV['ZENDESK_USER_EMAIL']
  config.password = ENV['ZENDESK_USER_PASSWORD']

  config.retry = true
end


#
# Just count how many ticket IDs per year or next line will count total tickets
# puts "Total Tickets: #{@client.tickets.count}"
#

puts "Total Tickets 2012"
puts @client.search(:query => "type:ticket group_id:20188163 status:closed updated_at>2012-01-01 updated_at<2013-01-01").count
puts "Total Tickets 2013"
puts @client.search(:query => "type:ticket group_id:20188163 status:closed updated_at>2013-01-01 updated_at<2014-01-01").count
puts "Total Tickets 2014"
puts @client.search(:query => "type:ticket group_id:20188163 status:closed updated_at>2014-01-01 updated_at<2015-01-01").count
puts "Total Tickets 2015"
puts @client.search(:query => "type:ticket group_id:20188163 status:closed updated_at>2015-01-01 updated_at<2016-01-01").count
puts "Total Tickets 2016"
puts @client.search(:query => "type:ticket group_id:20188163 status:closed updated_at>2016-01-01 updated_at<2017-01-01").count
puts "Total Tickets 2017"
puts @client.search(:query => "type:ticket group_id:20188163 status:closed updated_at>2017-01-01 updated_at<2018-01-01").count
