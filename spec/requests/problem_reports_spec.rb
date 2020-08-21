require "json"
require "csv"
require "plek"
require "gds_api/test_helpers/content_store"
require "rails_helper"

describe "Problem reports" do
  include GdsApi::TestHelpers::ContentStore

  # In order to improve information and services on GOV.UK
  # As a publisher
  # I want to record and view bugs, gripes submitted by GOV.UK users

  let(:hmrc) { Organisation.where(slug: "hm-revenue-customs").first }
  let(:vat_rates_content_store_response) do
    {
      base_path: "/vat-rates",
      title: "VAT Rates",
      links: {
        organisations: [
          {
            content_id: "6667cce2-e809-4e21-ae09-cb0bdc1ddda3",
            base_path: "/hm-revenue-customs",
            title: "HM Revenue & Customs",
            document_type: "organisation",
          },
        ],
      },
    }
  end

  it "calculates the problem report totals by day" do
    Timecop.travel Time.utc(2013, 2, 11)

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
    stub_content_store_has_item("/vat-rates", vat_rates_content_store_response)

    zendesk_request = expect_zendesk_to_receive_ticket(
      "subject" => "/vat-rates",
      "requester" => hash_including("email" => ZENDESK_ANONYMOUS_TICKETS_REQUESTER_EMAIL),
      "tags" => %w[anonymous_feedback public_form report_a_problem inside_government govuk_referrer page_owner/hmrc],
      "comment" => { "body" =>
"url: http://www.dev.gov.uk/vat-rates
what_doing: Eating sandwich
what_wrong: Fell on floor
user_agent: Safari
referrer: http://www.dev.gov.uk/pay-vat
javascript_enabled: true
" },
    )

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

  context "reviewing for spam" do
    let(:problem_report_1)  { create(:problem_report) }
    let(:problem_report_2)  { create(:problem_report) }
    let(:problem_report_3)  { create(:problem_report) }

    context "when succesfully supplied with a list of problem feedback reviews" do
      before do
        json_payload = {
          reviewed_problem_report_ids:
          {
            "#{problem_report_1.id}": true,
            "#{problem_report_2.id}": true,
            "#{problem_report_3.id}": false,
          },
        }.to_json

        put "/anonymous-feedback/problem-reports/mark-reviewed-for-spam",
            params: json_payload,
            headers: { "CONTENT_TYPE" => "application/json", "HTTP_ACCEPT" => "application/json" }
      end

      it "returns a 200 OK" do
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)).to eq("success" => true)
      end

      it "marks all supplied reports as reviewed" do
        expect(problem_report_1.reload.reviewed?).to eq true
        expect(problem_report_2.reload.reviewed?).to eq true
        expect(problem_report_3.reload.reviewed?).to eq true
      end

      it "marks the specified reports as spam" do
        expect(problem_report_1.reload.marked_as_spam?).to eq true
        expect(problem_report_2.reload.marked_as_spam?).to eq true
        expect(problem_report_3.reload.marked_as_spam?).to eq false
      end
    end

    context "when the supplied feedback reviews have already been reviewed" do
      before do
        problem_report_1.update!(reviewed: true, marked_as_spam: true)

        json_payload = {
          reviewed_problem_report_ids:
          {
            "#{problem_report_1.id}": false,
          },
        }.to_json

        put "/anonymous-feedback/problem-reports/mark-reviewed-for-spam",
            params: json_payload,
            headers: { "CONTENT_TYPE" => "application/json", "HTTP_ACCEPT" => "application/json" }
      end

      it "overwrite any reviewed reports with the supplied spam marking" do
        expect(problem_report_1.reload.reviewed?).to eq true
        expect(problem_report_1.reload.marked_as_spam?).to eq false
      end
    end

    context "when supplied with ids that are non-existent" do
      let(:id) { 1 }

      before do
        json_payload = {
          reviewed_problem_report_ids:
          {
            "#{id}": true,
          },
        }.to_json

        put "/anonymous-feedback/problem-reports/mark-reviewed-for-spam",
            params: json_payload,
            headers: { "CONTENT_TYPE" => "application/json", "HTTP_ACCEPT" => "application/json" }
      end

      it "returns a 404" do
        expect(response.status).to eq 404
        expect(JSON.parse(response.body)).to eq("success" => false)
      end
    end
  end

  context "when the user is not authenticated" do
    around do |example|
      ClimateControl.modify(GDS_SSO_MOCK_INVALID: "1") { example.run }
    end

    it "returns an unauthorized response for post" do
      post "/anonymous-feedback/problem-reports", params: {}
      expect(response).to be_unauthorized
    end

    it "returns an unauthorized response for totals" do
      get "/anonymous-feedback/problem-reports/2013-02-11/totals"
      expect(response).to be_unauthorized
    end

    it "returns an unauthorized response for mark-reviewed-for-spam" do
      put "/anonymous-feedback/problem-reports/mark-reviewed-for-spam", params: {}
      expect(response).to be_unauthorized
    end
  end

private

  def user_submits_a_problem_report(options)
    post "/anonymous-feedback/problem-reports",
         params: { "problem_report" => options }.to_json,
         headers: { "CONTENT_TYPE" => "application/json", "HTTP_ACCEPT" => "application/json" }
  end
end

describe "Retrieving Problem Reports" do
  let!(:gds) do
    create(:gds)
  end

  let(:what_wrong) { "Help" }
  let(:what_doing) { "Skiing" }
  let(:path)       { "/help" }
  let(:referrer)   { "https://www.gov.uk/browse" }
  let(:user_agent) { "Safari" }
  let(:created_at) { Date.new(2015, 0o2, 0o2) }

  let!(:problem_report) do
    create(
      :problem_report,
      what_wrong: what_wrong,
      what_doing: what_doing,
      path: path,
      referrer: referrer,
      user_agent: user_agent,
      created_at: created_at,
      content_item: create(:content_item, path: "/help", organisations: [gds]),
      reviewed: false,
    )
  end

  context "with a full set of filter parameters supplied" do
    let!(:earliest_problem_report_unreviewed) { create :problem_report, created_at: created_at - 2.weeks }
    let!(:earlier_problem_report_reviewed) { create :problem_report, created_at: created_at - 2.days, reviewed: true }
    let!(:later_problem_report_reviewed) { create :problem_report, created_at: created_at + 1.day, reviewed: true }
    let!(:later_problem_report_unreviewed) { create :problem_report, created_at: created_at + 1.day }

    let(:from_date) { created_at - 1.week }
    let(:to_date) { created_at + 1.day }

    before do
      stub_const("AnonymousContact::PAGE_SIZE", 2)

      get "/anonymous-feedback/problem-reports",
          params: { from_date: from_date.to_s, to_date: to_date.to_s, include_reviewed: true, page: 2 }
    end

    it "returns problem reports that fulfil those filters exactly" do
      expect(json_response["results"].length).to eq 2
      expect(json_response["results"].first.values).to include problem_report.id
      expect(json_response["results"].second.values).to include earlier_problem_report_reviewed.id
    end
  end
end
