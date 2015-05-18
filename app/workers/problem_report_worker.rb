class ProblemReportWorker
  include Sidekiq::Worker

  def perform(problem_report_params)
    problem_report = ProblemReport.create!(problem_report_params)
    ZendeskTicketWorker.perform_async(problem_report.id)
    ContentItemEnrichmentWorker.perform_async(problem_report.id)
  end
end
