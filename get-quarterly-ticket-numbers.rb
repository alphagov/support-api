require 'zendesk_api'

@client = ZendeskAPI::Client.new do |config|
  config.url = ENV['ZENDESK_URL']
  config.username = ENV['ZENDESK_USER_EMAIL']
  config.password = ENV['ZENDESK_USER_PASSWORD']

  config.retry = true
end

puts "Tickets: #{@client.tickets.count}"

#
# 2012
#

@q2_2012_tickets = []
@q3_2012_tickets = []
@q4_2012_tickets = []

#
# 2012/Q2
#

puts @client.search(:query => "type:ticket group_id:20188163 status:closed updated_at<2012-07-01").count

(1..50).each do |i|
  @client.search(:query => "type:ticket group_id:20188163 status:closed updated_at<2012-07-01").page(i).each do |ticket|
    @q2_2012_tickets << ticket['id']
  end
end

File.open("q2_2012_tickets", "w") { |file| file.write(@q2_2012_tickets) }

#
# 2012/Q3
#

puts @client.search(:query => "type:ticket group_id:20188163 status:closed updated_at<2012-07-01").count

(1..50).each do |i|
  @client.search(:query => "type:ticket group_id:20188163 status:closed updated_at<2012-10-01").page(i).each do |ticket|
    @q3_2012_tickets << ticket['id']
  end
end

File.open("q3_2012_tickets", "w") { |file| file.write(@q3_2012_tickets) }

#
# 2012/Q4
#

puts @client.search(:query => "type:ticket group_id:20188163 status:closed updated_at<2013-01-01").count

(1..50).each do |i|
  @client.search(:query => "type:ticket group_id:20188163 status:closed updated_at<2013-01-01").page(i).each do |ticket|
    @q3_2012_tickets << ticket['id']
  end
end

File.open("q4_2012_tickets", "w") { |file| file.write(@q3_2012_tickets) }


exit
exit


# 2013

@q1_2013_tickets = []
@q2_2013_tickets = []
@q3_2013_tickets = []
@q4_2013_tickets = []


#
# 2013/Q1
#

puts @client.search(:query => "type:ticket group_id:20188163 status:closed updated_at<2013-04-01").count

(1..50).each do |i|
  @client.search(:query => "type:ticket group_id:20188163 status:closed updated_at<2013-04-01").page(i).each do |ticket|
    @q1_2013_tickets << ticket['id']
  end
end

File.open("q1_2013_tickets", "w") { |file| file.write(@q1_2013_tickets) }

#
# 2013/Q2
#

puts @client.search(:query => "type:ticket group_id:20188163 status:closed updated_at<2013-07-01").count

(1..50).each do |i|
  @client.search(:query => "type:ticket group_id:20188163 status:closed updated_at<2013-07-01").page(i).each do |ticket|
    @q2_2013_tickets << ticket['id']
  end
end

File.open("q2_2013_tickets", "w") { |file| file.write(@q2_2013_tickets) }

#
# 2013/Q3
#

puts @client.search(:query => "type:ticket group_id:20188163 status:closed updated_at<2013-10-01").count

(1..50).each do |i|
  @client.search(:query => "type:ticket group_id:20188163 status:closed updated_at<2013-10-01").page(i).each do |ticket|
    @q3_2013_tickets << ticket['id']
  end
end

File.open("q3_2013_tickets", "w") { |file| file.write(@q3_2013_tickets) }

#
# 2013/Q4
#

puts @client.search(:query => "type:ticket group_id:20188163 status:closed updated_at<2014-01-01").count

(1..50).each do |i|
  @client.search(:query => "type:ticket group_id:20188163 status:closed updated_at<2014-01-01").page(i).each do |ticket|
    @q4_2013_tickets << ticket['id']
  end
end

File.open("q4_2013_tickets", "w") { |file| file.write(@q4_2013_tickets) }


