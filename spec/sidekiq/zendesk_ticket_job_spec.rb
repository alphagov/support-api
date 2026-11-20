require "rails_helper"

describe ZendeskTicketJob do
  describe "#perform" do
    it "creates the expected Zendesk ticket for a problem report" do
      problem_report = create(:problem_report, what_doing: "reading the page", what_wrong: "this page is shit")

      expect_zendesk_to_receive_ticket(
        "comment" => { "body" => <<~BODY },
          url: http://www.dev.gov.uk/vat-rates
          what_doing: reading the page
          what_wrong: this page is ****
          user_agent: Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.0;)
          referrer: http://www.example.com/foo
          javascript_enabled: true
        BODY
      )

      described_class.new.perform(problem_report.id)
    end

    it "increments the profane ticket metric when masking was applied" do
      problem_report = create(:problem_report, what_wrong: "this page is shit")
      stub_zendesk_ticket_creation

      expect(GovukStatsd).to receive(:increment).with("govuk_zendesk.profane_ticket")

      described_class.new.perform(problem_report.id)
    end

    it "does not increment the metric for clean feedback" do
      problem_report = create(:problem_report, what_wrong: "link was broken")
      stub_zendesk_ticket_creation

      expect(GovukStatsd).not_to receive(:increment)

      described_class.new.perform(problem_report.id)
    end
  end
end
