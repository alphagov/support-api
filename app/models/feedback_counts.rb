class FeedbackCounts
  def initialize(first_day_of_period, period_in_question)
    @first_day_of_period = first_day_of_period
    @period_in_question = period_in_question
  end

  def to_a
    absolute_count = feedback_counts.values.inject(:+)
    feedback_counts.map do |page_owner, count|
      {
        "_id" => feedback_count_id_for(page_owner),
        "_timestamp" => @first_day_of_period.to_time.iso8601,
        "period" => "month",
        "organisation_acronym" => page_owner,
        "comment_count" => count,
        "total_gov_uk_dept_and_policy_comment_count" => absolute_count,
      }
    end
  end

private

  def feedback_counts
    ProblemReport
      .only_actionable
      .with_known_page_owner
      .where(created_at: @period_in_question)
      .order("page_owner asc")
      .group(:page_owner)
      .count
  end

  def feedback_count_id_for(page_owner)
    "#{@first_day_of_period.strftime('%Y%m')}_#{page_owner}"
  end
end
