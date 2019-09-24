require "json"
require "rails_helper"

describe "Service feedback" do
  # In order to fix and improve my service (that's linked on GOV.UK)
  # As a service manager
  # I want to record and view bugs, gripes and improvement suggestions submitted by the service users

  before do
    Timecop.travel Time.utc(2013, 2, 28)
  end

  it "accepts submissions with comments" do
    user_submits_satisfaction_survey_on_done_page(
      slug: "find-court-tribunal",
      path: "/done/find-court-tribunal",
      service_satisfaction_rating: 3,
      details: "Make service less 'meh'",
      user_agent: "Safari",
      javascript_enabled: true,
    )

    expect(ServiceFeedback.where(slug: "find-court-tribunal").count).to eq(1)
  end

  it "accepts submissions without comments" do
    user_submits_satisfaction_survey_on_done_page(
      slug: "apply-carers-allowance",
      path: "/done/apply-carers-allowance",
      service_satisfaction_rating: 3,
      details: nil,
      javascript_enabled: true,
    )

    expect(ServiceFeedback.where(slug: "apply-carers-allowance").count).to eq(1)
  end

  it "validates the service feedback" do
    options = {
      slug: nil,
      path: "/done/apply-carers-allowance",
      service_satisfaction_rating: 7,
      javascript_enabled: true,
    }

    post "/anonymous-feedback/service-feedback",
         params: { "service_feedback" => options }.to_json,
         headers: { "CONTENT_TYPE" => "application/json", "HTTP_ACCEPT" => "application/json" }

    expect(response.status).to eq(422)
    expect(JSON.parse(response.body)["errors"]).to include(
      "Slug can't be blank",
      "Service satisfaction rating is not included in the list",
    )
  end

  context "when the user is not authenticated" do
    around do |example|
      ClimateControl.modify(GDS_SSO_MOCK_INVALID: "1") { example.run }
    end

    it "returns an unauthorized response" do
      post "/anonymous-feedback/service-feedback", params: {}
      expect(response).to be_unauthorized
    end
  end

  private

  def user_submits_satisfaction_survey_on_done_page(options)
    post "/anonymous-feedback/service-feedback",
         params: { "service_feedback" => options }.to_json,
         headers: { "CONTENT_TYPE" => "application/json", "HTTP_ACCEPT" => "application/json" }

    expect(response.status).to eq(202)
  end
end
