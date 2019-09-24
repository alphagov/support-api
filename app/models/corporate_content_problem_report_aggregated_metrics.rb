require "date"

class CorporateContentProblemReportAggregatedMetrics
  def initialize(year, month)
    @year = year
    @month = month
  end

  def to_h
    {
      "feedback_counts" => FeedbackCounts.new(first_day_of_period, period_in_question).to_a,
      "top_urls" => TopUrls.new(first_day_of_period, period_in_question).to_a
    }
  end

  def period_in_question
    first_day_of_period.beginning_of_day..first_day_of_period.end_of_month.end_of_day
  end

  def first_day_of_period
    Date.new(@year, @month, 1)
  end
end
