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

  it "accepts and saves problem reports from the 'Is there anything wrong with this page?' form" do
    zendesk_request = expect_zendesk_to_receive_ticket(
      "subject" => "/vat-rates",
      "requester" => hash_including("email" => ZENDESK_ANONYMOUS_TICKETS_REQUESTER_EMAIL),
      "tags" => %w{anonymous_feedback public_form report_a_problem inside_government govuk_referrer page_owner/hmrc},
      "comment" => { "body" =>
"url: http://www.dev.gov.uk/vat-rates
what_doing: Eating sandwich
what_wrong: Fell on floor
user_agent: Safari
referrer: http://www.dev.gov.uk/pay-vat
javascript_enabled: true
"})

    user_submits_a_problem_report(
      what_doing: "Eating sandwich",
      what_wrong: "Fell on floor",
      path: "/vat-rates",
      user_agent: "Safari",
      javascript_enabled: true,
      referrer: "http://www.dev.gov.uk/pay-vat",
      source: "inside_government",
      page_owner: "hmrc",
    )
    expect(response.status).to eq(202)

    results = Support::Requests::Anonymous::ProblemReport.where(
      what_doing: "Eating sandwich",
      what_wrong: "Fell on floor",
      path: "/vat-rates",
      user_agent: "Safari",
      javascript_enabled: true,
      referrer: "http://www.dev.gov.uk/pay-vat",
      source: "inside_government",
      page_owner: "hmrc",
    )
    expect(results.count).to eq(1)
    expect(zendesk_request).to have_been_made
  end

  it "validates the problem report" do
    user_submits_a_problem_report(
      what_wrong: "a" * (2**16 + 1),
      path: "/contact/govuk",
      javascript_enabled: true,
    )

    expect(response.status).to eq(422)
    expect(JSON.parse(response.body)["errors"]).to include(
      "What wrong is too long (maximum is 65536 characters)",
    )
  end

private
  def user_submits_a_problem_report(options)
    post '/anonymous-feedback/problem-reports',
         { "problem_report" => options }.to_json,
         {"CONTENT_TYPE" => 'application/json', 'HTTP_ACCEPT' => 'application/json'}
  end
end
