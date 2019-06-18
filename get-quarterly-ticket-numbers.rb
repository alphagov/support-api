require 'zendesk_api'

@client = ZendeskAPI::Client.new do |config|
  config.url = ENV['ZENDESK_URL']
  config.username = ENV['ZENDESK_USER_EMAIL']
  config.password = ENV['ZENDESK_USER_PASSWORD']

  config.retry = true
end

puts "Tickets: #{@client.tickets.count}"

@q2_2012_tickets = []
@q3_2012_tickets = []
@q4_2012_tickets = []

(1..35).each do |i|
  @client.search(:query => "type:ticket group_id:20188163 status:closed updated_at<2013-01-01").page(i).each do |ticket|
    @q2_2012_tickets << ticket['id']
  end
end

File.open("q2_2012_tickets", "w") { |file| file.write(@q2_2012_tickets) }

(36..70).each do |i|
  @client.search(:query => "type:ticket group_id:20188163 status:closed updated_at<2013-01-01").page(i).each do |ticket|
    @q3_2012_tickets << ticket['id']
  end
end

File.open("q3_2012_tickets", "w") { |file| file.write(@q3_2012_tickets) }
