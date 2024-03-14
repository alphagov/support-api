require "rails_helper"
require "date"

describe GenerateGlobalExportCsvWorker, type: :worker do
  let(:uploader) { instance_double(S3FileUploader) }
  subject(:worker) { described_class.new(uploader:) }

  before do
    expect(uploader).to receive(:save_file_to_s3)
  end

  it "sends a notification email" do
    mailer = double
    allow(mailer).to receive(:deliver_now)

    from_date = "2019-01-01"
    to_date = "2019-12-31"
    notification_email = "inside-government@digital.cabinet-office.gov.uk"
    file_url = %r{^http://support.dev.gov.uk/anonymous_feedback/export_requests/\d+$}

    expect(GlobalExportNotification).to receive(:notification_email).with(notification_email, file_url).and_return(mailer)

    subject.perform(
      "from_date" => from_date,
      "to_date" => to_date,
      "notification_email" => "inside-government@digital.cabinet-office.gov.uk",
    )
  end
end
