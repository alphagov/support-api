class DeduplicationWorker
  def self.start_deduplication_for_yesterday
    day = Date.yesterday
    Rails.logger.info("Deduping anonymous feedback for #{day}")
    AnonymousContact.deduplicate_contacts_created_between(
      day.beginning_of_day..day.end_of_day,
    )
  end

  def self.start_deduplication_for_recent_feedback
    current_time = Time.zone.now
    Rails.logger.info("Deduping anonymous feedback that arrived in the last 10 minutes")
    AnonymousContact.deduplicate_contacts_created_between(
      (current_time - 10.minutes)..current_time,
    )
  end
end
