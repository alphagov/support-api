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

    def zendesk_endpoint
      "https://govuk.zendesk.com/api/v2"
    end
  end
end
