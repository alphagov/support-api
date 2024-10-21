require "rails_helper"

describe GenerateFeedbackCsvJob, type: :worker do
  describe "#perform" do
    let(:feedback_export_request) { create(:feedback_export_request) }
    let(:uploader) { instance_double(S3FileUploader) }
    subject(:worker) { described_class.new(uploader:) }

    before do
      create(:anonymous_contact, created_at: Time.zone.local(2015, 5, 10))
      expect(uploader).to receive(:save_file_to_s3)
    end

    it "sends a notification email" do
      mailer = double
      expect(mailer).to receive(:deliver_now)
      expect(ExportNotification).to receive(:notification_email)
        .with("foo@example.com", "http://support.dev.gov.uk/anonymous_feedback/export_requests/#{feedback_export_request.id}")
        .and_return(mailer)
      subject.perform(feedback_export_request)
    end

    it "marks the request as generated" do
      Timecop.freeze(Time.zone.local(2015, 6, 1, 10)) do
        subject.perform(feedback_export_request)
      end

      expect(feedback_export_request.generated_at).to eq Time.zone.local(2015, 6, 1, 10)
    end
  end
end
