require 'date'

class ServiceFeedbackAggregatedMetrics
  def initialize(day, slug)
    @day = day
    @slug = slug
  end

  def to_h
    metadata.merge(aggregates)
  end

  private
  def aggregates
    {
      "comments" => filter_by_day_and_slug.with_comments_count,
      "total" => ratings.values.inject(:+) || 0,
    }.tap do |result|
      (1..5).each { |i| result["rating_#{i}"] = (ratings[i] || 0) }
    end
  end

  def ratings
    @results ||= Hash[
      filter_by_day_and_slug.
        aggregates_by_rating.
        reduce({}) { |m, r| m[r[:service_satisfaction_rating]] = r[:cnt]; m }
    ]
  end

  def metadata
    {
      "_id" => metric_id,
      "_timestamp" => start_timestamp,
      "period" => "day",
      "slug" => @slug
    }
  end

  def metric_id
    "#{@day.strftime("%Y%m%d")}_#{@slug}"
  end

  def start_timestamp
    @day.to_datetime.iso8601
  end

  def filter_by_day_and_slug
    ServiceFeedback.only_actionable.where(slug: @slug, created_at: time_interval)
  end

  def time_interval
    (@day.to_time...@day.to_time + 1.day)
  end
end
