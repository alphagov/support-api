class OldFeedbackDeleter
  BATCH_SIZE = 100_000
  RETENTION = 2.years

  def initialize(types:)
    @types = types
    @cutoff = RETENTION.ago
  end

  def delete
    total = feedback_to_delete.count
    yield "Deleting #{total} anonymous contacts (feedback) older than 2 years"
    yield "Types: #{@types.join(', ')}"

    start = Time.zone.now

    feedback_to_delete.in_batches(of: BATCH_SIZE).each_with_index do |batch, index|
      batch.delete_all

      elapsed = (Time.zone.now - start).round(1)
      deleted_count = [(index + 1) * BATCH_SIZE, total].min
      deleted_percent = ((deleted_count / total.to_f) * 100).round(1)

      yield "Deleted #{deleted_count}/#{total} (#{deleted_percent}%) in #{elapsed}s"
    end

    yield "Remaining anonymous contacts (feedback) older than 2 years:"
    yield "  of the provided types: #{feedback_to_delete.count}"
    yield "  of all types: #{old_feedback.count}"
  end

private

  def feedback_to_delete
    old_feedback.where(type: @types)
  end

  def old_feedback
    AnonymousContact.where(created_at: ...@cutoff)
  end
end
