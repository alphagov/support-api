require "helpers/zendesk_test_helpers"

module ZendeskRequestMockingExtensions
  def expect_zendesk_to_receive_ticket(opts)
    stub_zendesk_ticket_creation_with_body("ticket" => hash_including(opts))
  end
end

RSpec.configure do |c|
  c.include Zendesk::TestHelpers
  c.include ZendeskRequestMockingExtensions
end
