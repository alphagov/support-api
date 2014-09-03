require 'rails_helper'
require 'support/requests/anonymous/deduplication_worker'

module Support
  module Requests
    module Anonymous
      describe DeduplicationWorker do
        it "removes duplicate anonymous feedback for yesterday" do
          Timecop.travel Date.new(2013,2,11)

          expect(AnonymousContact).
            to receive(:deduplicate_contacts_created_between).
            with(Date.new(2013,2,10).beginning_of_day..Date.new(2013,2,10).end_of_day)

          DeduplicationWorker.start_deduplication_for_yesterday
        end
      end
    end
  end
end
