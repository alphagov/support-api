require 'support/requests/anonymous/long_form_contact'

class LongFormContactWorker
  include Sidekiq::Worker

  def perform(long_form_contact_params)
    contact = Support::Requests::Anonymous::LongFormContact.create!(long_form_contact_params)
    ZendeskTicketWorker.perform_async(contact.id)
  end
end
