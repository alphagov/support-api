require 'support/requests/anonymous/anonymous_contact'

module Support
  module Requests
    module Anonymous
      class ServiceFeedback < AnonymousContact
        validates_presence_of :slug, :service_satisfaction_rating
        validates :details, length: { maximum: 2 ** 16 }
        validates_inclusion_of :service_satisfaction_rating, in: (1..5).to_a
      end
    end
  end
end
