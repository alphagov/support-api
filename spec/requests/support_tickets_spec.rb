require "rails_helper"

describe "Support Tickets" do
  it "responds succesfully" do
    stub_zendesk_ticket_creation
    zendesk_has_valid_user_with_email("someone@example.com")

    post "/support-tickets",
         params: {
           subject: "Feedback for app",
           tags: %w[app_name],
           description: "Ticket details go here.",
           priority: "normal",
           requester: { locale_id: 1, email: "someone@example.com", name: "Some user" },
           collaborators: %w[a@b.com c@d.com],
           custom_fields: [
             { id: 7_948_652_819_356, value: "cr_inaccuracy" },
             { id: 7_949_106_580_380, value: "cr_benefits" },
           ],
           ticket_form_id: 123,
         }

    expect(response.code).to eq("201")
    expect(response_hash).to include("status" => "success")
  end

  it "sends the feedback to Zendesk" do
    zendesk_has_valid_user_with_email("someone@example.com")
    zendesk_request = expect_zendesk_to_receive_ticket(
      "subject" => "Feedback for app",
      "tags" => %w[app_name],
      "comment" => {
        "body" => "Ticket details go here.",
      },
    )

    post "/support-tickets",
         params: {
           subject: "Feedback for app",
           tags: %w[app_name],
           requester: { locale_id: 1, email: "someone@example.com", name: "Some user" },
           description: "Ticket details go here.",
         }

    expect(zendesk_request).to have_been_made
  end

  it "responds unsuccessfully if the support ticket isn't valid" do
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
