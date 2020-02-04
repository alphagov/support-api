require "s3_file_uploader"

class GenerateGlobalExportCsvWorker
  include Sidekiq::Worker

  def perform(export_params)
    filename, contents = GlobalExportCsvGenerator.new(
      Date.strptime(export_params["from_date"], "%Y-%m-%d").beginning_of_day,
      Date.strptime(export_params["to_date"], "%Y-%m-%d").end_of_day,
      export_params["exclude_spam"],
    ).call

    s3_file = S3FileUploader.save_file_to_s3(filename, contents)

    GlobalExportNotification.notification_email(export_params["notification_email"], s3_file.key).deliver_now
  end
end
