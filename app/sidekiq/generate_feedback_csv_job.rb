require "s3_file_uploader"

class GenerateFeedbackCsvJob
  include Sidekiq::Job

  def initialize(uploader: S3FileUploader.new)
    @uploader = uploader
  end

  def perform(*args)
    feedback_export_request = case args.first
                              when Integer
                                FeedbackExportRequest.find(args.first)
                              when FeedbackExportRequest
                                args.first
                              end

    csv = feedback_export_request.generate_csv
    @uploader.save_file_to_s3(feedback_export_request.filename, csv)

    feedback_export_request.touch(:generated_at)

    begin
      ExportNotification.notification_email(feedback_export_request.notification_email, feedback_export_request.url).deliver_now
    rescue Notifications::Client::BadRequestError => e
      raise if ENV["SENTRY_CURRENT_ENV"] !~ /integration|staging/ || e.message !~ /team-only API key/
    end
  end
end

GenerateFeedbackCsvWorker = GenerateFeedbackCsvJob ## TODO: Remove once queued jobs at the time of the upgrade are complete
