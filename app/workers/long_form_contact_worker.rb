require 'support/requests/anonymous/long_form_contact'

class LongFormContactWorker
  include Sidekiq::Worker

  def perform(long_form_contact_params)
    Support::Requests::Anonymous::LongFormContact.new(long_form_contact_params).save!
  end
end
