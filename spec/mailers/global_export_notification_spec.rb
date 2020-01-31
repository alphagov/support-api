require "rails_helper"

RSpec.describe GlobalExportNotification, type: :mailer do
  describe "notification_email" do
    subject(:mail) { GlobalExportNotification.notification_email("foo@example.com", "http://www.example.com/foo.csv") }

    it "is sent from the no reply address" do
      expect(mail.from).to eq ["inside-government@digital.cabinet-office.gov.uk"]
    end

    it "is sent to the correct recipient" do
      expect(mail.to).to eq ["foo@example.com"]
    end

    it "contains the URL" do
      expect(mail.body).to include "http://www.example.com/foo.csv"
    end
  end
end
