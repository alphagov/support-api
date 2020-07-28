class PerformancePlatformServiceFeedbackMetrics
  def initialize(day:, slug:)
    @day = day
    @slug = slug
  end

  def call
    counts.merge(metadata)
  end

private

  attr_reader :day, :slug

  def counts
    {
      "rating_1" => ratings[1] || 0,
      "rating_2" => ratings[2] || 0,
      "rating_3" => ratings[3] || 0,
      "rating_4" => ratings[4] || 0,
      "rating_5" => ratings[5] || 0,
      "total" => ratings.values.inject(:+),
      "comments" => service_feedback_with_comments.count,
    }
  end

  def metadata
    {
      "_id" => "#{day.strftime('%Y%m%d')}_#{slug}",
      "_timestamp" => day.to_time.iso8601,
      "period" => "day",
      "slug" => slug,
    }
  end

  def ratings
    aggregated_feedback_items = AggregatedServiceFeedback
      .where(path: path, created_at: time_interval)

    aggregated_feedback_items.each_with_object({}) do |item, memo|
      memo[item.service_satisfaction_rating] = item.details.to_i
    end
  end

  def path
    "/done/#{slug}"
  end

  def service_feedback_with_comments
    ServiceFeedback.only_actionable.where(slug: slug, created_at: time_interval).with_comments
  end

  def time_interval
    day.beginning_of_day..day.end_of_day
  end
end
