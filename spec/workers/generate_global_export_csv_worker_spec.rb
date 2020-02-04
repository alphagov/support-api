require "rails_helper"
require "date"

describe GenerateGlobalExportCsvWorker, type: :worker do
  subject(:worker) { described_class.new }
  before do
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

  it "has the expected filename" do
    from_date = "2019-01-01"
    to_date = "2019-12-31"
    described_class.new.perform(
      "from_date" => from_date,
      "to_date" => to_date,
      "notification_email" => "inside-government@digital.cabinet-office.gov.uk",
    )

    file = @directory.files.get("feedex_#{from_date}T00:00:00Z_#{to_date}T23:59:59Z.csv")
    expect(file).not_to be nil
    rows = file.body.split("\n")
    expect(rows.count).to eq 1
    expect(rows.first).to eq "date,report_count"
  end
end
