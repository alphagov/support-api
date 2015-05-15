require 'rails_helper'
require 'date'

describe ServiceFeedback do
  it { should validate_presence_of(:service_satisfaction_rating) }
  it { should allow_value(nil).for(:details) }
  it { should validate_presence_of(:slug) }
  it { should validate_inclusion_of(:service_satisfaction_rating).in_range(1..5) }

  before do
    create(:service_feedback, service_satisfaction_rating: 1, slug: "a")
    create(:service_feedback, service_satisfaction_rating: 2, slug: "a", details: "meh")
    create(:service_feedback, service_satisfaction_rating: 5, slug: "b")
  end

  it "aggregates by rating" do
    expect(ServiceFeedback.aggregates_by_rating).to eq(
      1 => 1,
      2 => 1,
      3 => 0,
      4 => 0,
      5 => 1
    )
  end

  it "aggregates by comment" do
    expect(ServiceFeedback.with_comments_count).to eq(1)
  end

  it "provides a list of available slugs" do
    expect(ServiceFeedback.transaction_slugs).to eq(["a", "b"])
  end
end
