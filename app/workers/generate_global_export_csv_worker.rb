require "s3_file_uploader"

class GenerateGlobalExportCsvWorker
  include Sidekiq::Worker

  def initialize(uploader: S3FileUploader.new)
    @uploader = uploader
  end

  def perform(export_params)
    feedback_export_request = FeedbackExportRequest.new(notification_email: export_params["notification_email"])

    filename, contents = GlobalExportCsvGenerator.new(
      Date.strptime(export_params["from_date"], "%Y-%m-%d").beginning_of_day,
      Date.strptime(export_params["to_date"], "%Y-%m-%d").end_of_day,
      export_params["exclude_spam"],
    ).call

    feedback_export_request.filename = filename

    @uploader.save_file_to_s3(filename, contents)

    feedback_export_request.save!
    feedback_export_request.touch(:generated_at)

    GlobalExportNotification.notification_email(export_params["notification_email"], feedback_export_request.url).deliver_now
  end
end
