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

  it "generates a hash of attributes and omits the optional attributes if value was not provided" do
    support_ticket = described_class.new(
      subject: "Feedback for app",
      description: "Ticket details go here.",
    )

    expect(support_ticket.zendesk_ticket_attributes).to eq(
      "subject" => "Feedback for app",
      "comment" => {
        "body" => "Ticket details go here.",
      },
    )
  end
end
