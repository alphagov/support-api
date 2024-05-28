require "rails_helper"

describe "Support Tickets" do
  it "responds succesfully" do
    stub_zendesk_ticket_creation

    post "/support-tickets",
         params: {
           subject: "Feedback for app",
           tags: %w[app_name],
           user_agent: "Safari",
           description: "Ticket details go here.",
         }

    expect(response.code).to eq("201")
    expect(response_hash).to include("status" => "success")
  end

  it "sends the feedback to Zendesk" do
    zendesk_request = expect_zendesk_to_receive_ticket(
      "subject" => "Feedback for app",
      "tags" => %w[app_name],
      "body" => <<-TICKET_BODY.strip_heredoc,
                 [User agent]
                 Safari

                 [Details]
                 Ticket details go here.
      TICKET_BODY
    )

    post "/support-tickets",
         params: {
           subject: "Feedback for app",
           tags: %w[app_name],
           user_agent: "Safari",
           description: "Ticket details go here.",
         }

    expect(zendesk_request).to have_been_made
  end

  it "responds unsuccessfully if the feedback isn't valid" do
    post "/support-tickets",
         params: { subject: "Feedback for app" }

    expect(response.code).to eq("422")
    expect(response_hash).to include("status" => "error")
  end

  it "returns error if the subject field is empty" do
    post "/support-tickets",
         params: { description: "Ticket details go here." }

    expect(response_hash).to include("errors" => include("subject" => include("can't be blank")))
  end

  it "returns error if the description field is empty" do
    post "/support-tickets",
         params: { subject: "Feedback for app" }

    expect(response_hash).to include("errors" => include("description" => include("can't be blank")))
  end

  def response_hash
    JSON.parse(response.body)
  end
end
