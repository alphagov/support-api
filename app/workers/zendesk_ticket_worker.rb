require 'zendesk/long_form_contact_ticket'
require 'zendesk/problem_report_ticket'
require 'support/requests/anonymous'

class ZendeskTicketWorker
  include Sidekiq::Worker
  include Support::Requests::Anonymous

  def perform(anonymous_contact_id)
    anonymous_contact = AnonymousContact.find(anonymous_contact_id)
    ticket_attributes = ticket_for(anonymous_contact).attributes
    GDS_ZENDESK_CLIENT.ticket.create!(HashWithIndifferentAccess.new(ticket_attributes))
  end

private
  def ticket_for(anonymous_contact)
    case anonymous_contact
    when LongFormContact then Zendesk::LongFormContactTicket.new(anonymous_contact)
    when ProblemReport then Zendesk::ProblemReportTicket.new(anonymous_contact)
    end
  end
end
