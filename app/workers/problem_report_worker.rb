require 'support/requests/anonymous/problem_report'

class ProblemReportWorker
  include Sidekiq::Worker

  def perform(problem_report_params)
    problem_report = Support::Requests::Anonymous::ProblemReport.create!(problem_report_params)
    ZendeskTicketWorker.perform_async(problem_report.id)
  end
end
