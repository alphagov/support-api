ENV["PACT_DO_NOT_TRACK"] = "true"

require "pact/provider/rspec"
require "webmock/rspec"
require ::File.expand_path("../../config/environment", __dir__)

Pact.configure do |config|
  config.reports_dir = "spec/reports/pacts"
  config.include WebMock::API
  config.include WebMock::Matchers
end

WebMock.allow_net_connect!

def url_encode(str)
  ERB::Util.url_encode(str)
end

Pact.service_provider "Support API" do
  honours_pact_with "GDS API Adapters" do
    if ENV["PACT_URI"]
      pact_uri(ENV["PACT_URI"])
    else
      base_url = "https://govuk-pact-broker-6991351eca05.herokuapp.com"
      path = "pacts/provider/#{url_encode(name)}/consumer/#{url_encode(consumer_name)}"
      version_modifier = "versions/#{url_encode(ENV.fetch('PACT_CONSUMER_VERSION', 'branch-main'))}"

      pact_uri("#{base_url}/#{path}/#{version_modifier}")
    end
  end
end

Pact.provider_states_for "GDS API Adapters" do
  provider_state "the parameters are valid" do
    set_up do
      params = {
        subject: "Feedback for app",
        tags: %w[app_name],
        user_agent: "Safari",
        description: "There is something wrong with this page.",
      }
      SupportTicket.new(params)
    end
  end

  provider_state "the required parameters are not provided" do
    set_up do
      params = { subject: "Feedback for app" }

      SupportTicket.new(params)
    end
  end
end
