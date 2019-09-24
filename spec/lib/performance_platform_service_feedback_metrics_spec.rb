require "rails_helper"
require "performance_platform_service_feedback_metrics"

describe PerformancePlatformServiceFeedbackMetrics do
  subject(:metric_generator) {
    described_class.new(day: Date.new(2013, 2, 10), slug: "apply-carers-allowance")
  }

  context "with valid aggregated feedback" do
    before do
      create(:aggregated_service_feedback,
             service_satisfaction_rating: 1,
             slug: "abcde",
             created_at: Date.new(2013, 2, 10),
             details: 1,
            )
      create(:aggregated_service_feedback,
             service_satisfaction_rating: 3,
             slug: "apply-carers-allowance",
             created_at: Date.new(2013, 2, 10),
             details: 4,
            )
      create(:aggregated_service_feedback,
             service_satisfaction_rating: 2,
             slug: "apply-carers-allowance",
             created_at: Date.new(2013, 2, 10),
             details: 57,
            )

      create(:service_feedback,
             service_satisfaction_rating: 2,
             details: "this is an awesome service",
             slug: "apply-carers-allowance",
             created_at: Date.new(2013, 2, 10),
            )
    end

    it "generates the metadata" do
      expect(metric_generator.call).to include(
        "_id" => "20130210_apply-carers-allowance", # id based on the slug and date
        "period" => "day",
        "_timestamp" => "2013-02-10T00:00:00+00:00",
        "slug" => "apply-carers-allowance",
      )
    end

    it "includes rating summaries" do
      expect(metric_generator.call).to include(
        "rating_1" => 0,
        "rating_2" => 57,
        "rating_3" => 4,
        "rating_4" => 0,
        "rating_5" => 0,
        "total"    => 61,
        "comments" => 1,
      )
    end
  end
end
