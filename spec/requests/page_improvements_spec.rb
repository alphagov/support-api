require 'rails_helper'

describe "Page Improvements" do
  it "responds succesfully" do
    stub_zendesk_ticket_creation

    post '/page-improvements', { path: '/service-manual/agile', description: 'I have a problem' }

    expect(response.code).to eq('201')
    expect(response_hash).to include('status' => 'success')
  end

  it "sends the feedback to Zendesk" do
    zendesk_request = expect_zendesk_to_receive_ticket(
      "subject" => "/service-manual/agile",
      "comment" => {
        "body" => <<-TICKET_BODY.strip_heredoc
                    [Details]
                    I have a problem

                    [Name]
                    John

                    [Email]
                    john@example.com

                    [Path]
                    /service-manual/agile

                    [User agent]
                    Safari
                  TICKET_BODY
      }
    )

    post '/page-improvements', {
      path: '/service-manual/agile',
      description: 'I have a problem',
      name: 'John',
      email: 'john@example.com',
      user_agent: 'Safari',
    }

    expect(zendesk_request).to have_been_made
  end

  it "responds unsuccessfully if the feedback isn't valid" do
    post '/page-improvements', { path: '/service-manual/agile' }

    expect(response.code).to eq('422')
    expect(response_hash).to include('status' => 'error')
  end

  it "returns errors if the feedback isn't valid" do
    post '/page-improvements', { path: '/service-manual/agile' }

    expect(response_hash).to include('errors' => include('description' => include("can't be blank")))
  end

  def response_hash
    JSON.parse(response.body)
  end
end
