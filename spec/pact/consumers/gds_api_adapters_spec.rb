require "rails_helper"
require "pact/rspec"

RSpec.describe "Verify consumers of Support API", :pact do
  http_pact_provider "Support API", opts: {
    http_port: 9292,
    pact_uri: ENV["PACT_URI"],
    broker_url: ENV.fetch("PACT_BROKER_BASE_URL", "https://govuk-pact-broker-6991351eca05.herokuapp.com"),
    consumer_name: "GDS API Adapters",
    consumer_version_selectors: [
      { branch: ENV.fetch("PACT_CONSUMER_VERSION", "branch-main").delete_prefix("branch-") },
    ],
    log_level: :info,
    fail_if_no_pacts_found: true,
  }

  provider_state "the parameters are valid" do
    set_up do
      WebMock::API.stub_request(:post, "https://govuk.zendesk.com/api/v2/tickets")
        .to_return(
          status: 210,
          body: { "status" => "success" }.to_json,
          headers: { "Content-Type" => "application/json" },
        )
    end
  end

  provider_state "the required parameters are not provided" do
    set_up do
      params = { subject: "Feedback for app" }
      SupportTicket.new(params)
    end
  end
end
