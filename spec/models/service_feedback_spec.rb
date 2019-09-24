require "rails_helper"
require "date"

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

  it "provides a list of available slugs" do
    expect(ServiceFeedback.transaction_slugs).to eq(%w[a b])
  end
end
