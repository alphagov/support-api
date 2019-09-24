class GenerateFeedbackCsvWorker
  include Sidekiq::Worker

  def perform(*args)
    feedback_export_request = case args.first
                              when Integer
                                FeedbackExportRequest.find(args.first)
                              when FeedbackExportRequest
                                args.first
                              end

    csv = feedback_export_request.generate_csv
    self.class.save_file_to_s3(feedback_export_request.filename, csv)

    feedback_export_request.touch(:generated_at)

    ExportNotification.notification_email(feedback_export_request.notification_email, feedback_export_request.url).deliver_now
  end

  def self.save_file_to_s3(filename, csv)
    connection = Fog::Storage.new(
      provider: "AWS",
      region: ENV["AWS_REGION"],
      aws_access_key_id: ENV["AWS_ACCESS_KEY_ID"],
      aws_secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"]
    )

    directory = connection.directories.get(ENV["AWS_S3_BUCKET_NAME"])

    directory.files.create(
      key: filename,
      body: csv
    )
  end
end
