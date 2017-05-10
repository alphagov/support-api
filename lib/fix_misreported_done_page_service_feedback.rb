class FixMisreportedDonePageServiceFeedback
  def initialize(start_date, end_date, logger)
    @start_date = start_date
    @end_date = end_date
    @logger = logger
  end

  def fix_all!
    all_done_page_paths.each do |done_page_path|
      service_slug = done_page_path.gsub("/done/", '')
      fix!(service_slug)
    end
  end

  def fix!(service_slug)
    done_page_path = "/done/#{service_slug}"
    logger.info("Investigating `#{done_page_path}` for misreported service feedback between #{start_date} and #{end_date}")

    [ServiceFeedback, AggregatedServiceFeedback].each do |feedback_type|
      misreported_service_feedback = fetch_misreported_service_feedback(service_slug, for_feedback_type: feedback_type)

      if misreported_service_feedback.count > 0
        logger.info("Fixing #{misreported_service_feedback.count} #{feedback_type.name} records for `#{done_page_path}`")
        misreported_service_feedback.update_all(path: done_page_path)
      else
        logger.info("No #{feedback_type.name} for `#{done_page_path}` was misreported")
      end
    end
  end

private

  attr_reader :logger, :start_date, :end_date

  def all_done_page_paths
    @all_done_page_paths ||= ServiceFeedback.matching_path_prefix('/done').select(:path).distinct.pluck(:path)
  end

  def fetch_misreported_service_feedback(service_slug, for_feedback_type: ServiceFeedback)
    for_feedback_type.created_between_days(start_date, end_date).where(path: "/#{service_slug}")
  end
end
