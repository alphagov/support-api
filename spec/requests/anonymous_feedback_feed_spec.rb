require "rails_helper"

describe "Anonymous feedback feed" do
  # In order to improve information and services on GOV.UK
  # As a publisher
  # I want to view bugs and gripes submitted by GOV.UK users

  context "by path" do
    let!(:problem_report) do
      create(:problem_report,
        what_wrong: "A",
        what_doing: "B",
        path: "/help",
        referrer: "https://www.gov.uk/browse",
        user_agent: "Safari",
        created_at: Time.utc(2015, 02, 03),
      )
    end

    let!(:service_feedback) do
      create(:service_feedback,
        slug: "waste_carrier_or_broker_registration",
        service_satisfaction_rating: 3,
        details: "meh",
        created_at: Time.utc(2015, 02, 02),
        path: "/done/waste_carrier_or_broker_registration",
        referrer: "https://www.wastecarrier.service.gov.uk",
        user_agent: "iPhone",
      )
    end

    let!(:long_form_contact) do
      create(:long_form_contact,
        details: "The VAT rate is wrong",
        created_at: Time.utc(2015, 02, 01),
        path: "/contact/govuk",
        referrer: "https://www.gov.uk/contact",
        user_specified_url: "https://www.gov.uk/vat-rates",
        user_agent: "iPhone",
      )
    end

    it "returns feedback with the appropriate fields in reverse chronological order" do
      get_json "/anonymous-feedback?path_prefixes[]=/"
      expect(response.status).to eq(200)

      expect(json_response["results"]).to eq([
        {
          "id" => problem_report.id,
          "type" => "problem-report",
          "what_wrong" => "A",
          "what_doing" => "B",
          "path" => "/help",
          "url" => "http://www.dev.gov.uk/help",
          "referrer" => "https://www.gov.uk/browse",
          "user_agent" => "Safari",
          "created_at" => "2015-02-03T00:00:00.000Z",
          "marked_as_spam" => false,
          "reviewed" => false,
        },
        {
          "id" => service_feedback.id,
          "type" => "service-feedback",
          "details" => "meh",
          "path" => "/done/waste_carrier_or_broker_registration",
          "url" => "http://www.dev.gov.uk/done/waste_carrier_or_broker_registration",
          "referrer" => "https://www.wastecarrier.service.gov.uk",
          "user_agent" => "iPhone",
          "service_satisfaction_rating" => 3,
          "slug" => "waste_carrier_or_broker_registration",
          "created_at" => "2015-02-02T00:00:00.000Z",
        },
        {
          "id" => long_form_contact.id,
          "type" => "long-form-contact",
          "details" => "The VAT rate is wrong",
          "user_specified_url" => "https://www.gov.uk/vat-rates",
          "path" => "/contact/govuk",
          "url" => "http://www.dev.gov.uk/contact/govuk",
          "referrer" => "https://www.gov.uk/contact",
          "user_agent" => "iPhone",
          "created_at" => "2015-02-01T00:00:00.000Z",
        },
      ])

      expect(json_response).to include(
        "total_count" => 3,
        "current_page" => 1,
        "pages" => 1,
        "page_size" => 50,
      )
    end
  end

  context "when the user is not authenticated" do
    around do |example|
      ClimateControl.modify(GDS_SSO_MOCK_INVALID: "1") { example.run }
    end

    it "returns an unauthorized response" do
      get "/anonymous-feedback?path_prefixes[]=/"
      expect(response).to be_unauthorized
    end
  end
end
