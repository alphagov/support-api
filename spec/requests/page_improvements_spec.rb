require "rails_helper"

describe "Page Improvements" do
  it "responds succesfully" do
    stub_zendesk_ticket_creation

    post "/page-improvements",
         params: { url: "https://gov.uk/service-manual/test", description: "I have a problem" }

    expect(response.code).to eq("201")
    expect(response_hash).to include("status" => "success")
  end

  it "sends the feedback to Zendesk" do
    zendesk_request = expect_zendesk_to_receive_ticket(
      "subject" => "https://gov.uk/service-manual/test",
      "comment" => {
        "body" => <<-TICKET_BODY.strip_heredoc
                    [Details]
                    I have a problem

                    [Name]
                    John

                    [Email]
                    john@example.com

                    [URL]
                    https://gov.uk/service-manual/test

                    [User agent]
                    Safari
                  TICKET_BODY
      }
    )

    post "/page-improvements",
         params: {
           url: "https://gov.uk/service-manual/test",
           description: "I have a problem",
           name: "John",
           email: "john@example.com",
           user_agent: "Safari",
         }

    expect(zendesk_request).to have_been_made
  end

  it "responds unsuccessfully if the feedback isn't valid" do
    post "/page-improvements",
         params: { url: "https://gov.uk/service-manual/test" }

    expect(response.code).to eq("422")
    expect(response_hash).to include("status" => "error")
  end

  it "returns errors if the feedback isn't valid" do
    post "/page-improvements",
         params: { url: "https://gov.uk/service-manual/test" }

    expect(response_hash).to include("errors" => include("description" => include("can't be blank")))
  end

  context "when the user is not authenticated" do
    around do |example|
      ClimateControl.modify(GDS_SSO_MOCK_INVALID: "1") { example.run }
    end

    it "returns an unauthorized response" do
      post "/page-improvements", params: { url: "https://gov.uk/service-manual/test" }
      expect(response).to be_unauthorized
    end
  end

  def response_hash
    JSON.parse(response.body)
  end
end
