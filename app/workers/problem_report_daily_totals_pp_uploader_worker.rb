require 'date'
require 'gds_api/performance_platform/data_in'
require 'gds_api/support_api'
require 'support/requests/anonymous/service_feedback_aggregated_metrics'

class ProblemReportDailyTotalsPPUploaderWorker
  include Sidekiq::Worker
  include Support::Requests::Anonymous

  def perform(year, month, day)
    logger.info("Uploading problem report daily totals for #{year}-#{month}-#{day}")
    pp_api = GdsApi::PerformancePlatform::DataIn.new(
      PP_DATA_IN_API[:url],
      bearer_token: PP_DATA_IN_API[:bearer_token]
    )
    support_api = GdsApi::SupportApi.new(Plek.find('support-api'))

    date = Date.new(year, month, day)
    totals = support_api.problem_report_daily_totals_for(date).to_hash

    request_details = transform_daily_problem_report_totals(date, totals)

    pp_api.submit_problem_report_daily_totals(request_details)
  end

  def self.run
    date = Date.yesterday
    perform_async(date.year, date.month, date.day)
    Sidekiq::Logging.logger.info("Problem report daily totals: queued upload for #{date}")
  end

private
  def transform_daily_problem_report_totals(date, totals)
    totals["data"].map do |entry|
      {
        "_id" => "#{date.to_time.strftime("%Y-%m-%d")}_#{entry["path"].gsub("/", "")}",
        "_timestamp" => date.to_time.iso8601,
        "period" => "day",
        "pagePath" => entry["path"],
        "total" => entry["total"],
      }
    end
  end
end
