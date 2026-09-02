require "rails_helper"
require "pact/v2"
require "pact/v2/rspec"

RSpec.describe "Verify consumers of Support API", :pact_v2 do
  consumer_version_tag = ENV.fetch("PACT_CONSUMER_VERSION", "branch-main")

  base_url = "https://govuk-pact-broker-6991351eca05.herokuapp.com"
  path = "pacts/provider/#{ERB::Util.url_encode('Support API')}/consumer/#{ERB::Util.url_encode('GDS API Adapters')}"

  http_pact_provider "Support API", opts: {
    http_port: 9292,
    pact_uri: "#{base_url}/#{path}/versions/#{ERB::Util.url_encode(consumer_version_tag)}",
    log_level: :info,
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
