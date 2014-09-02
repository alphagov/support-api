namespace :performance_platform_uploads do
  desc "Trigger an upload of service feedback data to the performance platform"
  task :push_service_feedback => :environment do
    require File.join(Rails.root, 'app', 'workers', 'service_feedback_pp_uploader_worker')
    require 'distributed_lock'

    DistributedLock.new('push_service_feedback_to_pp').lock do
      ServiceFeedbackPPUploaderWorker.run
      puts "ServiceFeedbackPPUploaderWorker invoked"
    end
  end
end
