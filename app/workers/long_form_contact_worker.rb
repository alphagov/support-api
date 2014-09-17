require 'support/requests/anonymous/long_form_contact'
require 'zendesk/long_form_contact_ticket'

class LongFormContactWorker
  include Sidekiq::Worker

  def perform(long_form_contact_params)
    contact = Support::Requests::Anonymous::LongFormContact.new(long_form_contact_params)
    contact.save!
    ticket = Zendesk::LongFormContactTicket.new(contact)
    ZendeskTicketWorker.perform_async(ticket.attributes)
  end
end
