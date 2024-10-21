class ProblemReportJob
  include Sidekiq::Job

  def perform(problem_report_params)
    problem_report = ProblemReport.create!(problem_report_params)
    ZendeskTicketJob.perform_async(problem_report.id)
    ContentItemEnrichmentJob.perform_async(problem_report.id)
  end
end

ProblemReportWorker = ProblemReportJob ## TODO: Remove once queued jobs at the time of the upgrade are complete
