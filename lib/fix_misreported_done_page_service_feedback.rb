class FixMisreportedDonePageServiceFeedback
  def initialize(start_date, end_date, logger)
    @start_date = start_date
    @end_date = end_date
    @logger = logger
  end

  def fix_all!
    all_done_page_paths.each do |done_page_path|
      service_slug = done_page_path.gsub("/done/", "")
      fix!(service_slug)
    end
  end

  def fix!(service_slug)
    done_page_path = "/done/#{service_slug}"
    logger.info("Investigating `#{done_page_path}` for misreported service feedback between #{start_date} and #{end_date}")

    fix_feedback(ServiceFeedback, service_slug, done_page_path)
    aggregated_feedback_fixed = fix_feedback(AggregatedServiceFeedback, service_slug, done_page_path)
    push_to_peformance_plaftorm(service_slug) if aggregated_feedback_fixed.positive?
  end

private

  attr_reader :logger, :start_date, :end_date

  def all_done_page_paths
    @all_done_page_paths ||= ServiceFeedback.matching_path_prefixes(["/done"]).select(:path).distinct.pluck(:path)
  end

  def fetch_misreported_service_feedback(service_slug, for_feedback_type: ServiceFeedback)
    for_feedback_type.created_between_days(start_date, end_date).where(path: "/#{service_slug}")
  end

  def fix_feedback(feedback_type, service_slug, done_page_path)
    misreported_service_feedback = fetch_misreported_service_feedback(service_slug, for_feedback_type: feedback_type)
    how_many_to_fix = misreported_service_feedback.count

    if how_many_to_fix.positive?
      logger.info("Fixing #{misreported_service_feedback.count} #{feedback_type.name} records for `#{done_page_path}`")
      misreported_service_feedback.update_all(path: done_page_path)
    else
      logger.info("No #{feedback_type.name} for `#{done_page_path}` was misreported")
    end

    how_many_to_fix
  end

  def date_range_for_feedback
    start_date..end_date
  end

  def push_to_peformance_plaftorm(service_slug)
    date_range_for_feedback.to_a.each do |feedback_date|
      ServiceFeedbackPPUploaderWorker.new.perform(feedback_date.year, feedback_date.month, feedback_date.day, service_slug)
      logger.info("Pushing aggregated `#{service_slug}` feedback for #{feedback_date.iso8601} to performance platform")
    end
  end
end
