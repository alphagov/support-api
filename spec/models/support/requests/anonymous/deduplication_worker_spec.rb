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

        it "removes anonymous feedback created in the last 10 minutes" do
          Timecop.travel Time.new(2013,2,11,12,0,0)

          expect(AnonymousContact).
            to receive(:deduplicate_contacts_created_between).
            with(Time.new(2013,2,11,11,50,0).to_i..Time.new(2013,2,11,12,0,0).to_i)

          DeduplicationWorker.start_deduplication_for_recent_feedback
        end
      end
    end
  end
end
