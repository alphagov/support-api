require "rails_helper"
require "zendesk/problem_report_ticket"
require "zendesk/long_form_contact_ticket"

describe Zendesk::Ticket do
  describe "#attributes comment body masking" do
    context "with a problem report" do
      let(:contact) do
        create(:problem_report,
               what_doing: "looking at the sh1t tax disc page",
               what_wrong: "the page about Essex was broken",
               path: "/browse/phonesex-education",
               user_agent: "Mozilla/5.0 (arse; shit; Windows NT 6.0;)",
               referrer: "http://www.example.com/urinal")
      end
      let(:ticket) { Zendesk::ProblemReportTicket.new(contact) }
      subject(:comment_body) { ticket.attributes[:comment]["body"] }

      it "masks profanity in free-text fields" do
        expect(comment_body).to include("what_doing: looking at the **** tax disc page")
        expect(comment_body).to include("what_wrong: the page about Essex was broken")
      end

      it "leaves metadata lines unmasked" do
        expect(comment_body).to include("url: #{Plek.new.website_root}/browse/phonesex-education")
        expect(comment_body).to include("user_agent: #{contact.user_agent}")
        expect(comment_body).to include("referrer: #{contact.referrer}")
        expect(comment_body).to include("javascript_enabled: true")
      end

      it "does not mask the subject" do
        expect(ticket.attributes[:subject]).to eq("/browse/phonesex-education")
      end

      it "keeps the '-' fallback for missing free-text fields" do
        contact.what_doing = nil
        expect(comment_body).to include("what_doing: -")
      end

      it "reports that masking was applied" do
        comment_body
        expect(ticket).to be_mask_applied
      end
    end

    context "with a long form contact" do
      let(:contact) do
        create(:long_form_contact,
               details: "your form is shit",
               user_specified_url: "https://www.gov.uk/shit-page")
      end
      let(:ticket) { Zendesk::LongFormContactTicket.new(contact) }
      subject(:comment_body) { ticket.attributes[:comment]["body"] }

      it "masks profanity in details" do
        expect(comment_body).to include("[Details]\nyour form is ****")
      end

      it "leaves the URL section unmasked" do
        expect(comment_body).to include("[URL]\nhttps://www.gov.uk/shit-page")
      end

      it "reports that masking was applied" do
        comment_body
        expect(ticket).to be_mask_applied
      end
    end

    context "with clean feedback" do
      let(:contact) { create(:problem_report, what_doing: "reading the page", what_wrong: "link was broken") }
      let(:ticket) { Zendesk::ProblemReportTicket.new(contact) }

      it "reports that masking was not applied" do
        ticket.attributes
        expect(ticket).not_to be_mask_applied
      end
    end

    it "masks all user-text fields in a single bridge call per ticket" do
      contact = create(:problem_report, what_doing: "one", what_wrong: "two")
      ticket = Zendesk::ProblemReportTicket.new(contact)

      allow(ProfanityFilter).to receive(:mask).and_call_original

      ticket.attributes
      ticket.attributes # second render must not spawn another subprocess

      expect(ProfanityFilter).to have_received(:mask).once.with(%w[one two])
    end

    context "kill switch" do
      around do |example|
        previous = ENV["ZENDESK_PROFANITY_MASKING"]
        example.run
        ENV["ZENDESK_PROFANITY_MASKING"] = previous
      end

      it "passes text through unmasked when disabled" do
        ENV["ZENDESK_PROFANITY_MASKING"] = "disabled"
        contact = create(:problem_report, what_wrong: "this page is shit")
        ticket = Zendesk::ProblemReportTicket.new(contact)

        expect(ticket.attributes[:comment]["body"]).to include("what_wrong: this page is shit")
        expect(ticket).not_to be_mask_applied
      end

      it "masks by default (no env var set)" do
        ENV.delete("ZENDESK_PROFANITY_MASKING")
        contact = create(:problem_report, what_wrong: "this page is shit")
        ticket = Zendesk::ProblemReportTicket.new(contact)

        expect(ticket.attributes[:comment]["body"]).to include("what_wrong: this page is ****")
      end
    end
  end
end
