require 'support/requests/anonymous/anonymous_contact'

module Support
  module Requests
    module Anonymous
      class DeduplicationWorker
        def self.start_deduplication_for_yesterday
          day = Date.yesterday
          Rails.logger.info("Deduping anonymous feedback for #{day}")
          AnonymousContact.deduplicate_contacts_created_between(
            day.beginning_of_day..day.end_of_day
          )
        end
      end
    end
  end
end
