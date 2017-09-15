require 'gds_api/performance_platform/data_out'

class BackfillHistoricAggregatedServiceFeedback
  def initialize(start_date, end_date, logger)
    @start_date = start_date
    @end_date = end_date
    @logger = logger
  end

  def import_from_performance_platform(transaction_slug)
    all_service_feedback_hash = fetch_all_service_feedback_hash(transaction_slug)

    if all_service_feedback_hash && slug_matches_aggregated_feedback?(transaction_slug)
      all_service_feedback_hash["data"].each do |service_feedback_hash|
        day_of_feedback_summary = Date.parse(service_feedback_hash["_day_start_at"])

        if within_specified_dates(day_of_feedback_summary) && transaction_slug == service_feedback_hash["slug"]
          aggregated_service_feedbacks = AggregatedServiceFeedback.where(
            created_at: day_of_feedback_summary.beginning_of_day..day_of_feedback_summary.end_of_day,
            path: path_for_transaction_slug(transaction_slug)
          )

          aggregated_service_feedbacks.each do |aggregated_feedback|
            feedback_rating_sum_from_performance_platform = service_feedback_hash["rating_#{aggregated_feedback.service_satisfaction_rating}"]

            if feedback_rating_sum_from_performance_platform == 0
              # Feedex does not contain aggregate records in the case where the
              # total is 0, therefore if the performance platform data
              # indicates 0, delete the aggregate record as it counts solely
              # duplicate records
              aggregated_feedback.delete
            else
              aggregated_feedback.update!(details: feedback_rating_sum_from_performance_platform, javascript_enabled: false)
            end
          end
        end
      end

      @logger.info("AggregateServiceFeedback for slug '#{transaction_slug}' overwritten where possible between dates #{@start_date} and #{@end_date}")
    end
  end

  private

  def within_specified_dates(day)
    day >= @start_date && day <= @end_date
  end

  def path_for_transaction_slug(slug)
    "/done/#{slug}"
  end

  def fetch_all_service_feedback_hash(transaction_slug)
    begin
      service_feedback_response = performance_platform_data_out.service_feedback(transaction_slug)
      all_service_feedback_hash = service_feedback_response.parsed_content

      if all_service_feedback_hash["data"].empty?
        @logger.warn("No data found for endpoint #{transaction_slug}")
        nil
      else
        all_service_feedback_hash
      end
    rescue GdsApi::HTTPNotFound
      @logger.warn("No endpoint found in performance platform for #{transaction_slug}")
      nil
    end
  end

  def performance_platform_data_out
    @data_out ||= GdsApi::PerformancePlatform::DataOut.new("https://www.performance.service.gov.uk")
  end

  def slug_matches_aggregated_feedback?(transaction_slug)
    if all_aggregated_feedback_paths.include?(path_for_transaction_slug(transaction_slug))
      true
    else
      @logger.warn("No aggregated feedback found for path #{path_for_transaction_slug(transaction_slug)}")
      false
    end
  end

  def all_aggregated_feedback_paths
    @paths ||= AggregatedServiceFeedback.select(:path).distinct.pluck(:path)
  end
end
