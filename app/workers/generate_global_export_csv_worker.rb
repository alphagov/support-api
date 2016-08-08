class GenerateGlobalExportCsvWorker
  include Sidekiq::Worker

  def perform(export_params)
    filename, contents = GlobalExportCsvGenerator.new(
      Date.strptime(export_params["from_date"], "%Y-%m-%d").beginning_of_day,
      Date.strptime(export_params["to_date"], "%Y-%m-%d").end_of_day,
    ).call

    GlobalExportNotification.notification_email(export_params["notification_email"], filename, contents).deliver_now
  end
end
