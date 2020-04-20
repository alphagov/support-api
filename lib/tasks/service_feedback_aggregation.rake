namespace :service_feedback_aggregation do
  desc "Extract service feedback of previous day to a different table, and add aggregated results"
  task daily: :environment do
    require "service_feedback_aggregator"
    require "distributed_lock"

    DistributedLock.new("service_feedback_aggregation").lock do
      date_range = Date.yesterday..Date.yesterday
      puts "Processing feedback from #{date_range.first} to #{date_range.last}"

      date_range.each do |date|
        ServiceFeedbackAggregator.new(date).run
      end

      puts "Service Feedback has been aggregated and extracted to a different table"
      Rails.logger.info "Daily service feedback aggregation has finished"
    end
  end

  desc "Extract service feedback of specified date to a different table, and add aggregated results. Enter date in DD-MM-YYYY format."
  task :date, %i[start_date end_date] => :environment do |_t, args|
    require "service_feedback_aggregator"

    start_date = Date.parse(args[:start_date])
    end_date = Date.parse(args[:end_date])
    puts "Processing feedback from #{start_date} to #{end_date}"

    (start_date..end_date).each do |date|
      ServiceFeedbackAggregator.new(date).run
    end

    puts "Service Feedback has been aggregated and extracted to a different table"
  end
end
