class GenerateFeedbackCsvWorker
  include Sidekiq::Worker

  CSV_ROOT = "/data/uploads/support-api/csvs"

  def perform(*args)
    feedback_export_request = case args.first
                              when Fixnum
                                FeedbackExportRequest.find(args.first)
                              when FeedbackExportRequest
                                args.first
                              end

    file = self.class.create_file(feedback_export_request.filename)

    feedback_export_request.generate_csv(file)
    file.close

    feedback_export_request.touch(:generated_at)

    ExportNotification.notification_email(feedback_export_request.notification_email, feedback_export_request.url).deliver_now
  end

  def self.create_file name
    FileUtils.mkdir_p(CSV_ROOT)
    File.new(File.join(CSV_ROOT, name), "w")
  end
end
