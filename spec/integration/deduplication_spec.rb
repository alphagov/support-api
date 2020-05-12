require "rails_helper"
require "time"
require "deduplication_worker"

describe "de-duplication" do
  let(:record1) do
    build(:service_feedback,
          service_satisfaction_rating: 5,
          details: "this service is great",
          slug: "some-tx",
          created_at: Time.parse("2013-01-15 12:00:00"))
  end

  let(:record2) do
    build(:service_feedback,
          service_satisfaction_rating: 3,
          details: "this service is meh",
          slug: "some-tx",
          created_at: Time.parse("2013-01-15 12:00:00"))
  end

  let(:record3) do
    build(:service_feedback,
          service_satisfaction_rating: 3,
          details: "this service is meh",
          slug: "some-tx",
          created_at: Time.parse("2013-01-15 12:00:01"))
  end

  context "nightly deduplication" do
    it "flags and removes duplicate service feedback from results" do
      record1.save!
      record2.save!
      record3.save!

      expect(AnonymousContact.only_actionable.count).to eq(3)

      # deduplicate
      Timecop.travel Time.parse("2013-01-16 00:30:00")
      DeduplicationWorker.start_deduplication_for_yesterday

      expect(AnonymousContact
        .only_actionable.order(:created_at).to_a).to eq([record1, record2])
    end
  end

  context "deduplication of recent feedback" do
    it "flags and removes duplicate service feedback from results" do
      record1.save!
      record2.save!
      record3.save!

      expect(AnonymousContact.only_actionable.count).to eq(3)

      Timecop.travel Time.parse("2013-01-15 12:08:00")
      DeduplicationWorker.start_deduplication_for_recent_feedback

      expect(AnonymousContact
        .only_actionable.order(:created_at).to_a).to eq([record1, record2])
    end
  end
end
