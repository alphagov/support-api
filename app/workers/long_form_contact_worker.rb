class LongFormContactWorker
  include Sidekiq::Worker

  def perform(long_form_contact_params, _govuk_headers = nil)
    contact = LongFormContact.create!(long_form_contact_params)
    ZendeskTicketWorker.perform_async(contact.id)
  end
end
