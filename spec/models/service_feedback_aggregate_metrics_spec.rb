require 'rails_helper'
require 'service_feedback_aggregated_metrics'

describe ServiceFeedbackAggregatedMetrics do
  context "with valid feedback" do
    before do
      create(:service_feedback,
        service_satisfaction_rating: 1,
        slug: "abcde",
        created_at: Date.new(2013,2,10)
      )
      create(:service_feedback,
        service_satisfaction_rating: 3,
        slug: "apply-carers-allowance",
        created_at: Date.new(2013,2,10)
      )
      create(:service_feedback,
        service_satisfaction_rating: 2,
        details: "abcde",
        slug: "apply-carers-allowance",
        created_at: Date.new(2013,2,10)
      )
    end

    subject { ServiceFeedbackAggregatedMetrics.new(Date.new(2013,2,10), "apply-carers-allowance").to_h }

    it "generates the metadata" do
      expect(subject).to include(
        "_id" => "20130210_apply-carers-allowance", # id based on the slug and date
        "period" => "day",
        "_timestamp" => "2013-02-10T00:00:00+00:00",
        "slug" => "apply-carers-allowance",
      )
    end

    it "includes rating summaries" do
      expect(subject).to include(
        "rating_1" => 0,
        "rating_2" => 1,
        "rating_3" => 1,
        "rating_4" => 0,
        "rating_5" => 0,
        "total"    => 2,
        "comments" => 1
      )
    end
  end

  context "for non-actionable comments, such as spam or dupes" do
    before do
      create(:service_feedback,
        is_actionable: false,
        reason_why_not_actionable: "abc",
        slug: "apply-carers-allowance",
        created_at: Date.new(2013,2,10)
      )
    end

    subject { ServiceFeedbackAggregatedMetrics.new(Date.new(2013,2,10), "apply-carers-allowance").to_h }

    it "doesn't count" do
      expect(subject["total"]).to eq(0)
    end
  end
end
