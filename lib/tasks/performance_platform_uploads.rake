namespace :performance_platform_uploads do
  desc "Trigger an upload of service feedback data to the performance platform"
  task push_service_feedback: :environment do
    require File.join(Rails.root, "app", "workers", "service_feedback_pp_uploader_worker")
    require "distributed_lock"

    DistributedLock.new("push_service_feedback_to_pp").lock do
      ServiceFeedbackPPUploaderWorker.run
      puts "ServiceFeedbackPPUploaderWorker invoked"
    end
  end

  desc "Trigger an upload of problem report daily totals data to the performance platform"
  task push_problem_report_daily_totals: :environment do
    require "distributed_lock"

    DistributedLock.new("push_problem_report_daily_totals_to_pp").lock do
      ProblemReportDailyTotalsPPUploaderWorker.run
      puts "ProblemReportDailyTotalsPPUploaderWorker invoked"
    end
  end

  desc "Trigger an upload of problem report stats (grouped by dept) to the performance platform"
  task push_problem_report_stats: :environment do
    require "distributed_lock"

    DistributedLock.new("support:problem_report_stats_to_pp").lock do
      ProblemReportStatsPPUploaderWorker.run
      puts "ProblemReportStatsPPUploaderWorker invoked"
    end
  end
end
