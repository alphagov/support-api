class LongFormContactWorker
  include Sidekiq::Worker

  def perform(long_form_contact_params)
    contact = LongFormContact.create!(long_form_contact_params)
    ZendeskTicketWorker.perform_async(contact.id)
  end
end
