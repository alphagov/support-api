class ServiceFeedbackAggregator

  attr_reader :reason_for_not_running

  def initialize(date)
    @date = date
  end

  def run
    raise_if_should_not_run
    ActiveRecord::Base.transaction do
      ActiveRecord::Base.connection.execute(create_aggregate)
      ActiveRecord::Base.connection.execute(copy_to_archive)
      ActiveRecord::Base.connection.execute(delete_from_anonymous_contacts)
    end
  end

private

  def raise_if_should_not_run
    if @date.to_date == Date.today
      raise "Cannot aggregate today's feedback until tomorrow"
    elsif aggregations_already_present?
      raise "Already aggregated for #{@date}"
    end
  end

  def aggregations_already_present?
    AggregatedServiceFeedback.where(created_at: @date.midnight..(@date + 1.day)).count > 0
  end

  def parsed_date(date)
    Date.parse(@date.to_s).midnight
  end

  def create_aggregate
    <<-SQL
    INSERT INTO anonymous_contacts (
      type,
      path,
      is_actionable,
      personal_information_status,
      created_at,
      updated_at,
      service_satisfaction_rating,
      details
    )
    SELECT
      'AggregatedServiceFeedback',
      path,
      true,
      'absent',
      DATE_TRUNC('day',created_at),
      DATE_TRUNC('day',created_at),
      service_satisfaction_rating,
      count(service_satisfaction_rating)
      FROM anonymous_contacts
      WHERE type = 'ServiceFeedback'
      AND created_at >= '#{@date}'
      AND created_at < '#{@date + 1.day}'
      GROUP BY 2, 5, 7;
    SQL
  end

  def copy_to_archive
    <<-SQL
    INSERT INTO archived_service_feedbacks (
      type,
      slug,
      created_at,
      service_satisfaction_rating
    )
    SELECT
      'ServiceFeedback',
      slug,
      DATE_TRUNC('day',created_at),
      service_satisfaction_rating
    FROM anonymous_contacts
    WHERE type = 'ServiceFeedback'
    AND created_at >= '#{@date}'
    AND created_at < '#{@date + 1.day}'
    SQL
  end

  def delete_from_anonymous_contacts
    <<-SQL
    DELETE FROM anonymous_contacts
    WHERE type = 'ServiceFeedback'
    AND details IS NULL
    AND created_at >= '#{@date}'
    AND created_at < '#{@date + 1.day}'
    SQL
  end
end
