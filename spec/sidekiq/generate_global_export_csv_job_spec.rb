require "rails_helper"
require "date"
require "ostruct"

describe GenerateGlobalExportCsvJob, type: :worker do
  let(:uploader) { instance_double(S3FileUploader) }
  subject(:worker) { described_class.new(uploader:) }
  let(:from_date) { "2019-01-01" }
  let(:to_date) { "2019-12-31" }
  let(:notification_email) { "inside-government@digital.cabinet-office.gov.uk" }
  let(:file_url) { %r{^http://support\.dev\.gov\.uk/anonymous_feedback/export_requests/\d+$} }

  before do
    expect(uploader).to receive(:save_file_to_s3)
  end

  it "sends a notification email" do
    mailer = double
    allow(mailer).to receive(:deliver_now)

    expect(GlobalExportNotification).to receive(:notification_email).with(notification_email, file_url).and_return(mailer)

    subject.perform(
      "from_date" => from_date,
      "to_date" => to_date,
      "notification_email" => notification_email,
    )
  end

  context "when Notifications::Client::BadRequestError is raised" do
    before do
      allow(GlobalExportNotification).to receive(:notification_email).with(any_args) do
        raise Notifications::Client::BadRequestError, OpenStruct.new(code: 400, body: "Can't send to this recipient using a team-only API key")
      end
    end

    it "does not raise exception in integration" do
      ClimateControl.modify(SENTRY_CURRENT_ENV: "integration") do
        expect {
          subject.perform(
            "from_date" => from_date,
            "to_date" => to_date,
            "notification_email" => notification_email,
          )
        }.not_to raise_error
      end
    end

    it "does not raise exception in staging" do
      ClimateControl.modify(SENTRY_CURRENT_ENV: "staging") do
        expect {
          subject.perform(
            "from_date" => from_date,
            "to_date" => to_date,
            "notification_email" => notification_email,
          )
        }.not_to raise_error
      end
    end

    it "raises exception in production" do
      ClimateControl.modify(SENTRY_CURRENT_ENV: "production") do
        expect {
          subject.perform(
            "from_date" => from_date,
            "to_date" => to_date,
            "notification_email" => notification_email,
          )
        }.to raise_error(Notifications::Client::BadRequestError)
      end
    end
  end
end
