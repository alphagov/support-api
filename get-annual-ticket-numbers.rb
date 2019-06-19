require 'zendesk_api'

@client = ZendeskAPI::Client.new do |config|
  config.url = ENV['ZENDESK_URL']
  config.username = ENV['ZENDESK_USER_EMAIL']
  config.password = ENV['ZENDESK_USER_PASSWORD']

  config.retry = true
end


#
# 2016 TEMPORARY
#

@y2016_tickets = []

#
puts "Total Tickets 2016"
#

puts @client.search(:query => "type:ticket group_id:20188163 status:closed updated_at>2016-01-01 updated_at<2017-01-01").count

(1..1000).each do |i|
  @client.search(:query => "type:ticket group_id:20188163 status:closed updated_at>2016-01-01 updated_at<2017-01-01").page(i).each do |ticket|
    @y2016_tickets << ticket['id']
  end
end

File.open("y2016_tickets", "w") { |file| file.write(@y2016_tickets) }



exit
exit


#
# Just count how many ticket IDs per year
#
# puts "Total Tickets: #{@client.tickets.count}"
#
# puts "Total Tickets 2012"
# puts @client.search(:query => "type:ticket group_id:20188163 status:closed updated_at>2012-01-01 updated_at<2013-01-01").count
# puts "Total Tickets 2013"
# puts @client.search(:query => "type:ticket group_id:20188163 status:closed updated_at>2013-01-01 updated_at<2014-01-01").count
# puts "Total Tickets 2014"
# puts @client.search(:query => "type:ticket group_id:20188163 status:closed updated_at>2014-01-01 updated_at<2015-01-01").count
# puts "Total Tickets 2015"
# puts @client.search(:query => "type:ticket group_id:20188163 status:closed updated_at>2015-01-01 updated_at<2016-01-01").count
# puts "Total Tickets 2016"
# puts @client.search(:query => "type:ticket group_id:20188163 status:closed updated_at>2016-01-01 updated_at<2017-01-01").count
# puts "Total Tickets 2017"
# puts @client.search(:query => "type:ticket group_id:20188163 status:closed updated_at>2017-01-01 updated_at<2018-01-01").count
#


#
# 2012
#

@y2012_tickets = []


puts @client.search(:query => "type:ticket group_id:20188163 status:closed updated_at>2012-01-01 updated_at<2013-01-01").count

(1..1000).each do |i|
  @client.search(:query => "type:ticket group_id:20188163 status:closed updated_at>2012-01-01 updated_at<2013-01-01").page(i).each do |ticket|
    @y2012_tickets << ticket['id']
  end
end

File.open("y2012_tickets", "w") { |file| file.write(@y2012_tickets) }


#
# 2013
#

@y2013_tickets = []

#
puts "Total Tickets 2013"
#

puts @client.search(:query => "type:ticket group_id:20188163 status:closed updated_at>2013-01-01 updated_at<2014-01-01").count

(1..1000).each do |i|
  @client.search(:query => "type:ticket group_id:20188163 status:closed updated_at>2013-01-01 updated_at<2014-01-01").page(i).each do |ticket|
    @y2013_tickets << ticket['id']
  end
end

File.open("y2013_tickets", "w") { |file| file.write(@y2013_tickets) }


#
# 2014
#

@y2014_tickets = []

#
puts "Total Tickets 2014"
#

puts @client.search(:query => "type:ticket group_id:20188163 status:closed updated_at>2014-01-01 updated_at<2015-01-01").count

(1..1000).each do |i|
  @client.search(:query => "type:ticket group_id:20188163 status:closed updated_at>2014-01-01 updated_at<2015-01-01").page(i).each do |ticket|
    @y2014_tickets << ticket['id']
  end
end

File.open("y2014_tickets", "w") { |file| file.write(@y2014_tickets) }


#
# 2015
#

@y2015_tickets = []

#
puts "Total Tickets 2015"
#

puts @client.search(:query => "type:ticket group_id:20188163 status:closed updated_at>2015-01-01 updated_at<2016-01-01").count

(1..100).each do |i|
  @client.search(:query => "type:ticket group_id:20188163 status:closed updated_at>2015-01-01 updated_at<2016-01-01").page(i).each do |ticket|
    @y2015_tickets << ticket['id']
  end
end

File.open("y2015_tickets", "w") { |file| file.write(@y2015_tickets) }



#
# 2016
#

@y2016 = []

#
puts "Total Tickets 2016"
#

puts @client.search(:query => "type:ticket group_id:20188163 status:closed updated_at>2016-01-01 updated_at<2017-01-01").count

(1..100).each do |i|
  @client.search(:query => "type:ticket group_id:20188163 status:closed updated_at>2016-01-01 updated_at<2017-01-01").page(i).each do |ticket|
    @y2016_tickets << ticket['id']
  end
end

File.open("y2016_tickets", "w") { |file| file.write(@y2016_tickets) }


#
# 2017
#

@y2017 = []

#
puts "Total Tickets 2017"
#

puts @client.search(:query => "type:ticket group_id:20188163 status:closed updated_at>2017-01-01 updated_at<2018-01-01").count

(1..100).each do |i|
  @client.search(:query => "type:ticket group_id:20188163 status:closed updated_at>2017-01-01 updated_at<2018-01-01").page(i).each do |ticket|
    @y2017_tickets << ticket['id']
  end
end

File.open("y2017_tickets", "w") { |file| file.write(@y2017_tickets) }
