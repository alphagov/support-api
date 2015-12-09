require 'json'
require 'csv'
require 'plek'
require 'gds_api/test_helpers/content_api'
require 'gds_api/test_helpers/content_store'
require 'rails_helper'

describe "Problem reports" do
  include GdsApi::TestHelpers::ContentApi
  include GdsApi::TestHelpers::ContentStore

  # In order to improve information and services on GOV.UK
  # As a publisher
  # I want to record and view bugs, gripes submitted by GOV.UK users

  let(:hmrc) { Organisation.where(slug: 'hm-revenue-customs').first }
  let(:vat_rates_content_api_response) {
    api_response = artefact_for_slug("vat-rates").tap do |hash|
      hash["tags"] = [
        {
          content_id: "6667cce2-e809-4e21-ae09-cb0bdc1ddda3",
          slug: "hm-revenue-customs",
          web_url: "https://www.gov.uk/government/organisations/hm-revenue-customs",
          title: "HM Revenue & Customs",
          details: {
            type: "organisation",
          }
        }
      ]
    end
  }

  it "calculates the problem report totals by day" do
    Timecop.travel Time.utc(2013,2,11)

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
    content_api_has_an_artefact("vat-rates", vat_rates_content_api_response)
    content_store_does_not_have_item('/vat-rates')

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

    results = ProblemReport.where(
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

    expect(results.first.content_item.path).to eq("/vat-rates")
    expect(results.first.content_item.organisations).to eq([hmrc])
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

  context "fetching" do
    let!(:gds) {
      create(:gds)
    }
    let!(:problem_report) {
      create(:problem_report,
        what_wrong: "A",
        what_doing: "B",
        path: "/help", # this will automatically be assigned to GDS
        referrer: "https://www.gov.uk/browse",
        user_agent: "Safari",
        created_at: Date.new(2015,02,02),
        content_item: create(:content_item, path: "/help", organisations: [gds]),
      )
    }

    let(:expected_output) {
      {
        "id" => problem_report.id,
        "type" => "problem-report",
        "what_wrong" => "A",
        "what_doing" => "B",
        "url" => "http://www.dev.gov.uk/help",
        "referrer" => "https://www.gov.uk/browse",
        "user_agent" => "Safari",
      }
    }

    it "filters the results by a time period" do
      get_json "/anonymous-feedback/problem-reports/2015-02"
      expect(response.status).to eq(200)
      expect(json_response.size).to eq(1)
      expect(json_response.first).to include(expected_output)

      get_json "/anonymous-feedback/problem-reports/2015-02-02"
      expect(json_response.size).to eq(1)
      expect(json_response.first).to include(expected_output)

      get_json "/anonymous-feedback/problem-reports/2015-01"
      expect(response.status).to eq(204)

      get_json "/anonymous-feedback/problem-reports/2015-02-03"
      expect(response.status).to eq(204)
    end

    context "for a particular organisation" do
      it "returns not found if the org doesn't exist" do
        get_json "/anonymous-feedback/problem-reports/2015-02?organisation_slug=hm-revenue-customs"

        expect(response.status).to eq(404)
      end

      it "filters the results by a time period" do
        get_json "/anonymous-feedback/problem-reports/2015-02?organisation_slug=government-digital-service"
        expect(response.status).to eq(200)
        expect(json_response.size).to eq(1)
        expect(json_response.first).to include(expected_output)

        get_json "/anonymous-feedback/problem-reports/2015-02-02?organisation_slug=government-digital-service"
        expect(json_response.size).to eq(1)
        expect(json_response.first).to include(expected_output)

        get_json "/anonymous-feedback/problem-reports/2015-01?organisation_slug=government-digital-service"
        expect(response.status).to eq(204)

        get_json "/anonymous-feedback/problem-reports/2015-02-03?organisation_slug=government-digital-service"
        expect(response.status).to eq(204)
      end

      it "returns CSV output" do
        get "/anonymous-feedback/problem-reports/2015-02.csv?organisation_slug=government-digital-service"

        expect(response.status).to eq(200)
        csv_response = CSV.parse(response.body)

        expect(csv_response).to eq([
          ["where feedback was left", "creation date", "feedback", "user came from"],
          ["http://www.dev.gov.uk/help", "2015-02-02", "action: B\nproblem: A", "https://www.gov.uk/browse"],
        ])
      end
    end
  end

private
  def user_submits_a_problem_report(options)
    post '/anonymous-feedback/problem-reports',
         { "problem_report" => options }.to_json,
         {"CONTENT_TYPE" => 'application/json', 'HTTP_ACCEPT' => 'application/json'}
  end
end
