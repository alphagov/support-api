require "rails_helper"
require "service_feedback_aggregator"

describe ServiceFeedbackAggregator do
  let(:date) { Time.new(2013,2,10,10) }
  subject(:aggregator) { ServiceFeedbackAggregator.new(date) }

  context "when run with today's date" do
    let(:date) { Date.today }

    it "refuses to run" do
      expect { aggregator.run }.to raise_error("Cannot aggregate today's feedback until tomorrow")
      expect(AggregatedServiceFeedback.count).to eq(0)
    end
  end

  context "when aggregation has already happened" do
    before { create(:aggregated_service_feedback, created_at: date) }

    it "refuses to run" do
      expect { aggregator.run }.to raise_error("Already aggregated for #{date}")
      expect(AggregatedServiceFeedback.count).to eq(1) # it doesn't create a 2nd
    end
  end

  context "with two service feedback entries" do
    context "with the same rating" do
      before do
        2.times do
          create(:service_feedback,
                 service_satisfaction_rating: 1,
                 slug: "register-to-vote",
                 created_at: date,
                )
        end
      end

      it "creates an aggregated service feedback with a rating of 1" do
        aggregator.run
        expect(AggregatedServiceFeedback.pluck(:service_satisfaction_rating)).to eq [1]
      end

      it "creates an aggregated service feedback with a count of 2" do
        aggregator.run
        expect(AggregatedServiceFeedback.pluck(:details)).to eq ["2"]
      end

      it "archives the original service feedbacks" do
        expect{ aggregator.run }.to change{ ArchivedServiceFeedback.count }.from(0).to(2)
      end

      it "deletes service feedbacks from the anonymous contacts table" do
        expect{ aggregator.run }.to change{ ServiceFeedback.count }.from(2).to(0)
      end

      context "and a feedback entry that has details" do
        before do
          create(:service_feedback,
                 service_satisfaction_rating: 1,
                 slug: "register-to-vote",
                 details: "A fantastic service",
                 created_at: date,
                )
        end

        it "doesn't delete that entry" do
          aggregator.run
          expect(ServiceFeedback.count).to eq(1)
          expect(ServiceFeedback.pluck(:details)).to eq ["A fantastic service"]
        end
      end

      context "and a duplicate piece of feedback" do
        before do
          create(:duplicate_service_feedback,
                 service_satisfaction_rating: 1,
                 slug: "register-to-vote",
                 created_at: date,
                )
        end

        it "doesn't include it in the sum of feedback for that rating" do
          aggregator.run
          expect(AggregatedServiceFeedback.find_by(service_satisfaction_rating: 1).details).to eq "2"
        end
      end
    end

    context "with different ratings" do
      before do
        2.times do |i|
          create(:service_feedback,
                 service_satisfaction_rating: i+1,
                 slug: "register-to-vote",
                 created_at: date,
                )
        end
      end

      it "creates two aggregated service feedbacks with a rating of 1 and 2" do
        aggregator.run
        expect(AggregatedServiceFeedback.pluck(:service_satisfaction_rating)).to include(1, 2)
      end
    end

    context "with different dates" do
      before do
        2.times do |i|
          create(:service_feedback,
                 service_satisfaction_rating: 1,
                 slug: "register-to-vote",
                 created_at: date - i.days,
                )
        end
      end

      it "creates only one aggregated service feedback" do
        aggregator.run
        expect(AggregatedServiceFeedback.all.count).to eq 1
      end
    end
  end
end
