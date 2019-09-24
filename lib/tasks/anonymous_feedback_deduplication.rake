namespace :anonymous_feedback_deduplication do
  desc "Trigger deduplication for yesterday's anonymous feedback"
  task :nightly => :environment do
    require "deduplication_worker"
    require "distributed_lock"

    DistributedLock.new("anonymous_feedback_nightly_deduplication").lock do
      DeduplicationWorker.start_deduplication_for_yesterday
      Rails.logger.info "Nightly deduplication has finished"
    end
  end

  desc "Trigger deduplication for recently created anonymous feedback (run regularly)"
  task :recent => :environment do
    require "deduplication_worker"
    require "distributed_lock"

    DistributedLock.new("recent_feedback_deduplication").lock do
      DeduplicationWorker.start_deduplication_for_recent_feedback
      puts "Deduplication for recent feedback has finished"
    end
  end
end
