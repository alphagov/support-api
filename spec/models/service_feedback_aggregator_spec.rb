require 'rails_helper'
require 'service_feedback_aggregator'

describe ServiceFeedbackAggregator do
  let(:date)  { Time.new(2013,2,10,10)  }
  let(:slug)  { "done/register-to-vote" }
  let(:rating){ 1                       }

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

  let!(:service_feedback_aggregator) { ServiceFeedbackAggregator.new }

  context "aggregating service feedbacks" do

    before { service_feedback_aggregator.run(Time.new(2013,2,10)) }

    context "when there are two service feedbacks" do
      context "with the same rating" do
        it "there is one aggregated service feedback with a rating of 1" do
          expect(AggregatedServiceFeedback.all.map(&:service_satisfaction_rating)).to eq [1]
        end

        it "there is one aggregated service feedback with a count of 2" do
          expect(AggregatedServiceFeedback.all.map(&:details)).to eq ["2"]
        end
      end

      context "with different ratings" do
        let(:rating) { 2 }

        it "there are two aggregated service feedbacks with a rating of 1 and 2" do
          expect(AggregatedServiceFeedback.all.map(&:service_satisfaction_rating)).to eq([2,1])
        end
      end

      context "with different dates" do
        let(:date) { Time.new(2013,2,10,11) }

        it "there is only one aggregated service feedback" do
          expect(AggregatedServiceFeedback.all.count).to eq 1
        end
      end
    end
  end

  context "archiving service feedbacks" do
    let(:date) { Time.new(2013,2,11) }

    it "copies service feedbacks to the archived service feedback table" do
      expect(ArchivedServiceFeedback.count).to eq 0
      aggregator = ServiceFeedbackAggregator.new
      aggregator.run(Time.new(2013,2,11))
      expect(ArchivedServiceFeedback.count).to eq 1
    end
  end

  context "deleting service feedbacks" do
    let(:aggregator) { ServiceFeedbackAggregator.new }

    context "when they have no details" do
      it "deletes service feedbacks from the anonymous contacts table" do
        expect(ServiceFeedback.count).to eq 2
        aggregator.run(Time.new(2013,2,10))
        expect(ServiceFeedback.count).to eq 0
      end
    end

    context "when they have details" do
      it "doesn't delete service feedbacks from the anonymous contacts table" do
        create(
          :service_feedback,
          service_satisfaction_rating: 1,
          slug: "done/register-to-vote",
          details: "A fantastic service",
          created_at: Time.new(2013,2,10,10)
        )

        expect(ServiceFeedback.count).to eq 3
        aggregator.run(Time.new(2013,2,10))
        expect(ServiceFeedback.count).to eq 1
      end
    end
  end
end
