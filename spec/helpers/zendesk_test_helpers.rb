require "json"

module Zendesk
  module TestHelpers
    def stub_zendesk_ticket_creation(ticket_properties = nil)
      stub = stub_request(:post, "#{zendesk_endpoint}/tickets")
      stub.with(body: { ticket: ticket_properties }) unless ticket_properties.nil?
      stub.to_return(status: 201, body: { ticket: { id: 12_345 } }.to_json,
                     headers: { "Content-Type" => "application/json" })
    end

    def stub_zendesk_ticket_creation_with_body(body)
      stub_request(:post, "#{zendesk_endpoint}/tickets")
        .with(body:)
        .to_return(status: 201, body: { ticket: { id: 12_345 } }.to_json,
                   headers: { "Content-Type" => "application/json" })
    end

    def expect_zendesk_to_receive_ticket(opts)
      stub_zendesk_ticket_creation_with_body("ticket" => hash_including(opts))
    end

    def zendesk_has_no_user_with_email(email)
      stub_request(:get, "#{zendesk_endpoint}/users/search?query=#{email}")
        .to_return(body: { users: [], previous_page: nil, next_page: nil, count: 0 }.to_json,
                   headers: { "Content-Type" => "application/json" })
    end

    def zendesk_has_suspended_user_with_email(email)
      stub_request(:get, "#{zendesk_endpoint}/users/search?query=#{email}")
        .to_return(body: { users: [{ email:, suspended: true }] }.to_json,
                   headers: { "Content-Type" => "application/json" })
    end

    def zendesk_has_valid_user_with_email(email)
      stub_request(:get, "#{zendesk_endpoint}/users/search?query=#{email}")
        .to_return(body: { users: [{ email:, suspended: false }] }.to_json,
                   headers: { "Content-Type" => "application/json" })
    end

    def zendesk_endpoint
      "https://govuk.zendesk.com/api/v2"
    end
  end
end
