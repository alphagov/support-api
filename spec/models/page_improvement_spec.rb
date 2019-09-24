require "rails_helper"

describe PageImprovement, "validations" do
  it "validates presence of url" do
    page_improvement = described_class.new({})
    page_improvement.valid?

    expect(page_improvement.errors.messages).to include(url: include("can't be blank"))
  end

  it "validates presence of description" do
    page_improvement = described_class.new({})
    page_improvement.valid?

    expect(page_improvement.errors.messages).to include(description: include("can't be blank"))
  end
end

describe PageImprovement, "#zendesk_ticket_attributes" do
  it "generates a hash of attributes to create a Zendesk ticket" do
    page_improvement = described_class.new({
      url: "https://gov.uk/service-manual/test",
      description: "I love this page.",
      name: "John",
      email: "john@example.com",
      user_agent: "Safari",
    })

    expect(page_improvement.zendesk_ticket_attributes).to eq({
      "subject" => "https://gov.uk/service-manual/test",
      "comment" => {
        "body" => <<-TICKET_BODY.strip_heredoc,
                    [Details]
                    I love this page.

                    [Name]
                    John

                    [Email]
                    john@example.com

                    [URL]
                    https://gov.uk/service-manual/test

                    [User agent]
                    Safari
                  TICKET_BODY
      },
    })
  end

  it "generates a hash of attributes where the body omits the optional name and email" do
    page_improvement = described_class.new({
      url: "https://gov.uk/service-manual/test",
      description: "I love this page.",
      user_agent: "Safari",
    })

    expect(page_improvement.zendesk_ticket_attributes).to eq({
      "subject" => "https://gov.uk/service-manual/test",
      "comment" => {
        "body" => <<-TICKET_BODY.strip_heredoc,
                    [Details]
                    I love this page.

                    [Name]


                    [Email]


                    [URL]
                    https://gov.uk/service-manual/test

                    [User agent]
                    Safari
                  TICKET_BODY
      },
    })
  end
end
