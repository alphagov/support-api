require 'json'
require 'rails_helper'
require 'support/requests/anonymous/service_feedback'

describe "Long-form contacts" do
  # In order to improve information and services on GOV.UK
  # As a publisher
  # I want to record and view bugs, gripes and improvement suggestions submitted by GOV.UK users

  it "accepts long-form anonymous contacts from the GOV.UK support form" do
    user_submits_a_long_form_anonymous_contact(
      user_specified_url: "https://www.gov.uk/vat-rates",
      details: "Make service less 'meh'",
      path: "/contact/govuk",
      user_agent: "Safari",
      javascript_enabled: true,
    )
    expect(response.status).to eq(202)

    results = Support::Requests::Anonymous::LongFormContact.where(
      user_specified_url: 'https://www.gov.uk/vat-rates',
      path: "/contact/govuk",
      details: "Make service less 'meh'",
    )
    expect(results.count).to eq(1)
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

private
  def user_submits_a_long_form_anonymous_contact(options)
    post '/anonymous-feedback/long-form-contacts',
         { "long_form_contact" => options }.to_json,
         {"CONTENT_TYPE" => 'application/json', 'HTTP_ACCEPT' => 'application/json'}
  end
end
