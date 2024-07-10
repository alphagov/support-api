require "rails_helper"

describe SupportTicket, "validations" do
  it "validates presence of subject" do
    support_ticket = described_class.new({})
    support_ticket.valid?

    expect(support_ticket.errors.messages.to_h).to include(subject: include("can't be blank"))
  end

  it "validates presence of description" do
    support_ticket = described_class.new({})
    support_ticket.valid?

    expect(support_ticket.errors.messages.to_h).to include(description: include("can't be blank"))
  end
end

describe SupportTicket, "#zendesk_ticket_attributes" do
  it "generates a hash of attributes to create a Zendesk ticket" do
    support_ticket = described_class.new(
      subject: "Feedback for app",
      priority: "normal",
      requester: { "locale_id" => 1, "email" => "someone@exampe.com", "name" => "Some user" },
      collaborators: %w[a@b.com c@d.com],
      tags: %w[app_name],
      custom_fields: [
        { "id" => 7_948_652_819_356, "value" => "cr_inaccuracy" },
        { "id" => 7_949_106_580_380, "value" => "cr_benefits" },
      ],
      ticket_form_id: 123,
      description: "Ticket details go here.",
    )

    expect(support_ticket.zendesk_ticket_attributes).to eq(
      "subject" => "Feedback for app",
      "tags" => %w[app_name],
      "priority" => "normal",
      "requester" => { "locale_id" => 1, "email" => "someone@exampe.com", "name" => "Some user" },
      "collaborators" => %w[a@b.com c@d.com],
      "custom_fields" => [
        { "id" => 7_948_652_819_356, "value" => "cr_inaccuracy" },
        { "id" => 7_949_106_580_380, "value" => "cr_benefits" },
      ],
      "ticket_form_id" => 123,
      "comment" => {
        "body" => "Ticket details go here.",
      },
    )
  end

  it "generates a hash of attributes where the body omits the optional attributes" do
    support_ticket = described_class.new(
      subject: "Feedback for app",
      tags: %w[app_name],
      description: "Ticket details go here.",
    )

    expect(support_ticket.zendesk_ticket_attributes).to eq(
      "subject" => "Feedback for app",
      "tags" => %w[app_name],
      "comment" => {
        "body" => "Ticket details go here.",
      },
    )
  end
end
