require 'rails_helper'
require 'time'
require 'support/requests/anonymous/deduplication_worker'

describe "de-duplication" do
  it "flags and removes duplicate service feedback from results" do
    Timecop.travel Time.parse("2013-01-15 12:00:00")

    record1 = create(:service_feedback,
      service_satisfaction_rating: 5,
      details: "this service is great",
      slug: "some-tx",
      url: "https://www.gov.uk/done/some-tx"
    )

    record2 = create(:service_feedback,
      service_satisfaction_rating: 3,
      details: "this service is meh",
      slug: "some-tx",
      url: "https://www.gov.uk/done/some-tx"
    )

    Timecop.travel Time.parse("2013-01-15 12:00:01")

    record3 = create(:service_feedback,
      service_satisfaction_rating: 3,
      details: "this service is meh",
      slug: "some-tx",
      url: "https://www.gov.uk/done/some-tx"
    )

    expect(Support::Requests::Anonymous::AnonymousContact.only_actionable.count).to eq(3)

    # deduplicate
    Timecop.travel Time.parse("2013-01-16 00:30:00")
    Support::Requests::Anonymous::DeduplicationWorker.start_deduplication_for_yesterday

    expect(Support::Requests::Anonymous::AnonymousContact.
      only_actionable.order(:created_at).to_a).to eq([record1, record2])
  end

  after do
    Timecop.return
  end
end
