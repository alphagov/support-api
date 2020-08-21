require "date"
require "gds_api/performance_platform/data_in"

class ProblemReportDailyTotalsPPUploaderWorker
  include Sidekiq::Worker

  def perform(year, month, day)
    logger.info("Uploading problem report daily totals for #{year}-#{month}-#{day}")
    pp_api = GdsApi::PerformancePlatform::DataIn.new(
      PP_DATA_IN_API[:url],
      bearer_token: PP_DATA_IN_API[:bearer_token],
    )

    date = Time.utc(year, month, day)
    totals = ProblemReport.totals_for(date)

    request_details = transform_daily_problem_report_totals(date, totals)

    pp_api.submit_problem_report_daily_totals(request_details)
  end

  def self.run
    date = Date.yesterday
    perform_async(date.year, date.month, date.day)
    Sidekiq::Logging.logger.info("Problem report daily totals: queued upload for #{date}")
  end

private

  def transform_daily_problem_report_totals(date, report)
    report.map do |entry|
      {
        "_id" => "#{date.strftime('%Y-%m-%d')}_#{entry.path.gsub('/', '')}",
        "_timestamp" => date.to_time.iso8601,
        "period" => "day",
        "pagePath" => entry.path,
        "total" => entry.total,
      }
    end
  end
end
