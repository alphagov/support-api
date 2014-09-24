require 'json'
require 'rails_helper'

describe "Problem reports" do
  # In order to improve information and services on GOV.UK
  # As a publisher
  # I want to record and view bugs, gripes submitted by GOV.UK users

  it "calculates the problem report totals by day" do
    Timecop.travel Date.new(2013,2,11)

    create(:problem_report, path: "/vat-rates")
    create(:problem_report, path: "/vat-rates")
    create(:problem_report, path: "/tax-disc")

    get_json "/anonymous-feedback/problem-reports/2013-02-11/totals"

    expect(response.status).to eq(200)
    expect(json_response["data"]).to eq([
      { "path" => "/vat-rates", "total" => 2 },
      { "path" => "/tax-disc", "total" => 1 },
    ])
  end
end
