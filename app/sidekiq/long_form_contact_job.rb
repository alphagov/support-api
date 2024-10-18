class LongFormContactJob
  include Sidekiq::Job

  def perform(long_form_contact_params)
    contact = LongFormContact.create!(long_form_contact_params)
    ZendeskTicketJob.perform_async(contact.id)
  end
end

LongFormContactWorker = LongFormContactJob ## TODO: Remove once queued jobs at the time of the upgrade are complete
