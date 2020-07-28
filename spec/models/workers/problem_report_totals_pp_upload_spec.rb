require "rails_helper"
require "gds_api/test_helpers/support_api"
require "gds_api/test_helpers/performance_platform/data_in"

describe "problem report totals PP upload" do
  include GdsApi::TestHelpers::SupportApi
  include GdsApi::TestHelpers::PerformancePlatform::DataIn

  it "pushes data to the performance platform" do
    stub_upload_request = stub_problem_report_daily_totals_submission([
      {
        "_id" => "2014-09-29_vat-rates",
        "_timestamp" => "2014-09-29T00:00:00Z",
        "period" => "day",
        "pagePath" => "/vat-rates",
        "total" => 2,
      },
      {
        "_id" => "2014-09-29_tax-disc",
        "_timestamp" => "2014-09-29T00:00:00Z",
        "period" => "day",
        "pagePath" => "/tax-disc",
        "total" => 1,
      },
    ])

    class MockEntry
      attr_accessor :path, :total

      def initialize(path, total)
        @path = path
        @total = total
      end
    end

    allow(ProblemReport).to receive(:totals_for).and_return([
      MockEntry.new("/vat-rates", 2),
      MockEntry.new("/tax-disc", 1),
    ])

    Timecop.travel Time.utc(2014, 9, 30)

    ProblemReportDailyTotalsPPUploaderWorker.run

    expect(stub_upload_request).to have_been_made
  end
end
