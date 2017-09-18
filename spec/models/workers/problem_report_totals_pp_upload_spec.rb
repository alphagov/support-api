require "rails_helper"
require "gds_api/test_helpers/support_api"
require "gds_api/test_helpers/performance_platform/data_in"

describe "problem report totals PP upload" do
  include GdsApi::TestHelpers::SupportApi
  include GdsApi::TestHelpers::PerformancePlatform::DataIn

  it "pushes data to the performance platform" do
    response = {
      data: [
        { "path" => "/vat-rates", "total" => 2 },
        { "path" => "/tax-disc", "total" => 1 },
      ]
    }
    stub_support_api_problem_report_daily_totals_for(Date.new(2014, 9, 29), response.to_json)

    stub_upload_request = stub_problem_report_daily_totals_submission([
      {
        "_id" => "2014-09-29_vat-rates",
        "_timestamp" => "2014-09-29T00:00:00+00:00",
        "period" => "day",
        "pagePath" => "/vat-rates",
        "total" => 2
      },
      {
        "_id" => "2014-09-29_tax-disc",
        "_timestamp" => "2014-09-29T00:00:00+00:00",
        "period" => "day",
        "pagePath" => "/tax-disc",
        "total" => 1
      }
    ])

    Timecop.travel Time.utc(2014,9,30)

    ProblemReportDailyTotalsPPUploaderWorker.run

    expect(stub_upload_request).to have_been_made
  end
end
