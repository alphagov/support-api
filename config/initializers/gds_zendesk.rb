require 'yaml'
require 'gds_zendesk/client'
require 'gds_zendesk/dummy_client'

ZENDESK_ANONYMOUS_TICKETS_REQUESTER_EMAIL = "api-user@example.com"

GDS_ZENDESK_CLIENT = if Rails.env.development?
                       GDSZendesk::DummyClient.new(logger: Rails.logger)
                     elsif Rails.env.test?
                       GDSZendesk::Client.new(username: "abc", password: "def", logger: Rails.logger)
                     else
                       nil # this file is overwritten in prod
                     end
