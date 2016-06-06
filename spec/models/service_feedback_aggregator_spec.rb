require 'rails_helper'
require 'service_feedback_aggregator'

describe ServiceFeedbackAggregator do
  let(:date)  { Time.new(2013,2,10,10) }
  let(:slug)  { "done/register-to-vote" }
  let(:rating){ 1 }

  let!(:first_record) {
    create(
      :service_feedback,
      service_satisfaction_rating: 1,
      slug: "done/register-to-vote",
      created_at: Time.new(2013,2,10,10)
    )
  }

  let!(:second_record) {
    create(
    :service_feedback,
    service_satisfaction_rating: rating,
    slug: slug,
    created_at: date
    )
  }

  let!(:service_feedback_aggregator) { ServiceFeedbackAggregator.new(date) }

  context "aggregating service feedbacks" do

    before { service_feedback_aggregator.run }

    context "when there are two service feedbacks" do
      context "with the same rating" do
        it "creates an aggregated service feedback with a rating of 1" do
          expect(AggregatedServiceFeedback.pluck(:service_satisfaction_rating)).to eq [1]
        end

        it "creates an aggregated service feedback with a count of 2" do
          expect(AggregatedServiceFeedback.pluck(:details)).to eq ["2"]
        end
      end

      context "with different ratings" do
        let(:rating) { 2 }

        it "creates two aggregated service feedbacks with a rating of 1 and 2" do
          expect(AggregatedServiceFeedback.pluck(:service_satisfaction_rating)).to eq([2,1])
        end
      end

      context "with different dates" do
        let(:date) { Time.new(2013,2,10,11) }

        it "creates only one aggregated service feedback" do
          expect(AggregatedServiceFeedback.all.count).to eq 1
        end
      end

      context "when the date is today's date" do
        let(:date) { Time.now }

        it "doesn't run the aggregation" do
          expect(AggregatedServiceFeedback.all.count).to eq 0
        end
      end

      context "when there is already an aggregate for that date" do
        it "doesn't run the aggregation" do
          expect(AggregatedServiceFeedback.all.count).to eq 1
          expect(service_feedback_aggregator.run).to eq "Already aggregated"
          expect{ service_feedback_aggregator.run }.not_to change{ AggregatedServiceFeedback.count }
        end
      end
    end
  end

  context "archiving service feedbacks" do
    let(:date) { Time.new(2013,2,11) }

    it "copies service feedbacks to the archived service feedback table" do
      aggregator = ServiceFeedbackAggregator.new(Time.new(2013,2,11))
      expect{ aggregator.run }.to change{ ArchivedServiceFeedback.count }.from(0).to(1)
    end
  end

  context "deleting service feedbacks" do
    let(:aggregator) { ServiceFeedbackAggregator.new(date) }

    context "when they have no details" do
      it "deletes service feedbacks from the anonymous contacts table" do
        expect{ aggregator.run }.to change{ ServiceFeedback.count }.from(2).to(0)
      end
    end

    context "when they have details" do
      it "doesn't delete service feedbacks from the anonymous contacts table" do
        create(
          :service_feedback,
          service_satisfaction_rating: 1,
          slug: "done/register-to-vote",
          details: "A fantastic service",
          created_at: date
        )

        expect{ aggregator.run }.to change{ ServiceFeedback.count }.from(3).to(1)
      end
    end
  end
end
