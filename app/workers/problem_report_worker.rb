require 'support/requests/anonymous/problem_report'
require 'zendesk/problem_report_ticket'

class ProblemReportWorker
  include Sidekiq::Worker

  def perform(problem_report_params)
    problem_report = Support::Requests::Anonymous::ProblemReport.new(problem_report_params)
    problem_report.save!
    ticket = Zendesk::ProblemReportTicket.new(problem_report)
    ZendeskTicketWorker.perform_async(ticket.attributes)
  end
end
