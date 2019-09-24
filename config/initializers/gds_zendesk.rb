require "yaml"
require "gds_zendesk/client"
require "gds_zendesk/dummy_client"

ZENDESK_ANONYMOUS_TICKETS_REQUESTER_EMAIL = ENV["ZENDESK_ANONYMOUS_TICKET_EMAIL"] || "api-user@example.com"

GDS_ZENDESK_CLIENT = if Rails.env.development?
                       GDSZendesk::DummyClient.new(logger: Rails.logger)
                     else
                       GDSZendesk::Client.new(
                         username: ENV["ZENDESK_CLIENT_USERNAME"] || "abc",
                         password: ENV["ZENDESK_CLIENT_PASSWORD"] || "def",
                         logger: Rails.logger,
                       )
                     end
