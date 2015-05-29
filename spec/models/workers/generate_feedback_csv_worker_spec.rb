require 'rails_helper'
require 'fakefs/spec_helpers'

describe GenerateFeedbackCsvWorker, :type => :worker do
  describe ".create_file" do
    include FakeFS::SpecHelpers

    before { FakeFS.activate! }
    after { FakeFS.deactivate! }

    subject { GenerateFeedbackCsvWorker.create_file("foo.csv") }

    it "creates the file in the configured root" do
      subject
      expect(File.exist?("/data/uploads/feedback_explorer/foo.csv")).to be true
    end

    it { is_expected.to_not be_closed }
  end

  describe "#perform" do
    let(:feedback_export_request) { create(:feedback_export_request) }
    let!(:io) do
      StringIO.new.tap { |io| expect(described_class).to receive(:create_file).and_return(io) }
    end

    before do
      create(:anonymous_contact, created_at: Time.new(2015, 5, 10))
    end

    it "populates the file with the CSV for the request" do
      described_class.new.perform(feedback_export_request)
      expect(io.string.split("\n").count).to eq 2
    end

    it "closes the file" do
      described_class.new.perform(feedback_export_request)
      expect(io).to be_closed
    end

    it "sends a notification email" do
      mail = double
      expect(mail).to receive(:deliver_now)
      expect(ExportNotification).to receive(:notification_email).
        with("foo@example.com", "http://support.dev.gov.uk/anonymous_feedback/export_requests/#{feedback_export_request.id}").
        and_return(mail)
      described_class.new.perform(feedback_export_request)
    end

    it "marks the request as generated" do
      Timecop.freeze(Time.new(2015, 6, 1, 10)) do
        described_class.new.perform(feedback_export_request)
      end

      expect(feedback_export_request.generated_at).to eq Time.new(2015, 6, 1, 10)
    end
  end
end
