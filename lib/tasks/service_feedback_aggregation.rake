namespace :service_feedback_aggregation do
  desc "Extract service feedback of previous day to a different table, and add aggregated results"
  task :daily => :environment do
    require "service_feedback_aggregator"
    require "distributed_lock"

    DistributedLock.new("service_feedback_aggregation").lock do
      date_range = Date.yesterday..Date.yesterday
      aggregate(date_range)
      Rails.logger.info "Daily service feedback aggregation has finished"
    end
  end

  desc "Extract service feedback of specified date to a different table, and add aggregated results. Enter date in DD-MM-YYYY format."
  task :date, [:start_date, :end_date] => :environment do |t, args|
    require "service_feedback_aggregator"

    start_date = Date.parse(args[:start_date])
    end_date = Date.parse(args[:end_date])
    date_range = start_date..end_date

    aggregate(date_range)
  end

  def aggregate(date_range)
    puts "Processing feedback from #{date_range.first} to #{date_range.last}"
    date_range.each do |date|
      start_time = Time.now
      aggregator = ServiceFeedbackAggregator.new(date)
      aggregator.run
      end_time = Time.now
      puts "Aggregation complete for #{date}. Duration: #{end_time - start_time}"
    end
    puts "Service Feedback has been aggregated and extracted to a different table"
  end
end
