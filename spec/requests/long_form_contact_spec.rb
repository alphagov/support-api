require "json"
require "rails_helper"

describe "Long-form contacts" do
  # In order to improve information and services on GOV.UK
  # As a publisher
  # I want to record and view bugs, gripes and improvement suggestions submitted by GOV.UK users

  it "accepts and saves long-form anonymous contacts from the GOV.UK support form" do
    zendesk_request = expect_zendesk_to_receive_ticket(
      "subject" => "Feedback about https://www.gov.uk/vat-rates",
      "requester" => hash_including("email" => ZENDESK_ANONYMOUS_TICKETS_REQUESTER_EMAIL),
      "tags" => %w{anonymous_feedback public_form long_form_contact},
      "comment" => { "body" =>
"[Details]
Make page less 'meh'

[URL]
https://www.gov.uk/vat-rates

[Referrer]
Unknown

[User agent]
Safari

[JavaScript Enabled]
true
"})

    user_submits_a_long_form_anonymous_contact(
      user_specified_url: "https://www.gov.uk/vat-rates",
      details: "Make page less 'meh'",
      path: "/contact/govuk",
      user_agent: "Safari",
      javascript_enabled: true,
    )
    expect(response.status).to eq(202)

    results = LongFormContact.where(
      user_specified_url: "https://www.gov.uk/vat-rates",
      path: "/contact/govuk",
      details: "Make page less 'meh'",
    )
    expect(results.count).to eq(1)
    expect(zendesk_request).to have_been_made
  end

  it "validates the long-form contact" do
    user_submits_a_long_form_anonymous_contact(
      details: nil,
      path: "/contact/govuk",
      javascript_enabled: true,
    )

    expect(response.status).to eq(422)
    expect(JSON.parse(response.body)["errors"]).to include(
      "Details can't be blank",
    )
  end

  context "when the user is not authenticated" do
    around do |example|
      ClimateControl.modify(GDS_SSO_MOCK_INVALID: "1") { example.run }
    end

    it "returns an unauthorized response" do
      post "/anonymous-feedback/long-form-contacts", params: {}.to_json
      expect(response).to be_unauthorized
    end
  end

private

  def user_submits_a_long_form_anonymous_contact(options)
    post "/anonymous-feedback/long-form-contacts",
         params: { "long_form_contact" => options }.to_json,
         headers: { "CONTENT_TYPE" => "application/json", "HTTP_ACCEPT" => "application/json" }
  end
end
