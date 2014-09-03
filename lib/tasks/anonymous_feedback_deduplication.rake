desc "Trigger deduplication for yesterday's anonymous feedback"
task :anonymous_feedback_nightly_deduplication => :environment do
  require 'support/requests/anonymous/deduplication_worker'
  require 'distributed_lock'

  DistributedLock.new('anonymous_feedback_nightly_deduplication').lock do
    Support::Requests::Anonymous::DeduplicationWorker.start_deduplication_for_yesterday
    Rails.logger.info "Nightly deduplication has finished"
  end
end
