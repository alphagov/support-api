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

describe SupportTicket, "#attributes" do
  it "generates a hash of attributes to create a Zendesk ticket" do
    support_ticket = described_class.new(
      subject: "Feedback for app",
      tags: %w[app_name],
      user_agent: "Safari",
      description: "Ticket details go here.",
    )

    expect(support_ticket.attributes).to eq(
      "subject" => "Feedback for app",
      "tags" => %w[app_name],
      "body" => <<-TICKET_BODY.strip_heredoc,
                  [User agent]
                  Safari

                  [Details]
                  Ticket details go here.
      TICKET_BODY
    )
  end

  it "generates a hash of attributes where the body omits the optional user agent" do
    support_ticket = described_class.new(
      subject: "Feedback for app",
      tags: %w[app_name],
      description: "Ticket details go here.",
    )

    expect(support_ticket.attributes).to eq(
      "subject" => "Feedback for app",
      "tags" => %w[app_name],
      "body" => <<-TICKET_BODY.strip_heredoc,
                  [User agent]


                  [Details]
                  Ticket details go here.
      TICKET_BODY
    )
  end
end
