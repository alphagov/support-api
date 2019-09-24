require "rails_helper"

describe GenerateFeedbackCsvWorker, type: :worker do
  describe "#perform" do
    let(:feedback_export_request) { create(:feedback_export_request) }

    before do
      create(:anonymous_contact, created_at: Time.new(2015, 5, 10))

      Fog.mock!
      ENV["AWS_REGION"] = "eu-west-1"
      ENV["AWS_ACCESS_KEY_ID"] = "test"
      ENV["AWS_SECRET_ACCESS_KEY"] = "test"
      ENV["AWS_S3_BUCKET_NAME"] = "test-bucket"

      # Create an S3 bucket so the code being tested can find it
      connection = Fog::Storage.new(
        provider: "AWS",
        region: ENV["AWS_REGION"],
        aws_access_key_id: ENV["AWS_ACCESS_KEY_ID"],
        aws_secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
      )
      @directory = connection.directories.get(ENV["AWS_S3_BUCKET_NAME"]) || connection.directories.create(key: ENV["AWS_S3_BUCKET_NAME"])
    end

    it "populates the file with the CSV for the request" do
      described_class.new.perform(feedback_export_request)
      file = @directory.files.get(feedback_export_request.filename)
      expect(file.body.split("\n").count).to eq 2
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
