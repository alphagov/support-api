require "yaml"
require "zendesk_api"
require "zendesk/dummy_client"

GDS_ZENDESK_URL = "https://govuk.zendesk.com/api/v2/".freeze
ZENDESK_ANONYMOUS_TICKETS_REQUESTER_EMAIL = ENV["ZENDESK_ANONYMOUS_TICKET_EMAIL"] || "api-user@example.com"

GDS_ZENDESK_CLIENT = if Rails.env.development?
                       Zendesk::DummyClient.new(logger: Rails.logger)
                     else
                       ZendeskAPI::Client.new do |config|
                         config.url = GDS_ZENDESK_URL
                         config.username = ENV["ZENDESK_CLIENT_USERNAME"] || "abc"
                         config.password = ENV["ZENDESK_CLIENT_PASSWORD"] || "def"
                         config.logger = Rails.logger
                       end
                     end
