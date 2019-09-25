# This class uses a sliding window to identify duplicates within a certain period of time
# This assumes that data is being fed into the class in chronological order
class DuplicateDetector
  def initialize(fields_to_compare)
    @comparator = AnonymousFeedbackComparator.new(fields_to_compare)
    @records_in_sliding_window = []
  end

  def duplicate?(record)
    is_dupe = matches_any_in_sliding_window?(record)
    slide_window_to_include(record)
    is_dupe
  end

private

  def matches_any_in_sliding_window?(record)
    @records_in_sliding_window.any? { |saved_record| @comparator.same?(saved_record, record) }
  end

  def slide_window_to_include(record)
    @records_in_sliding_window.select! { |r| @comparator.created_within_a_short_interval?(r, record) }
    @records_in_sliding_window << record
  end
end

class AnonymousFeedbackComparator
  DUPLICATION_INTERVAL_IN_SECONDS = 5

  def initialize(fields_to_compare)
    @fields_to_compare = fields_to_compare
  end

  def same?(record1, record2)
    fields_same?(record1, record2) && created_within_a_short_interval?(record1, record2)
  end

  def created_within_a_short_interval?(record1, record2)
    (record1["created_at"] - record2["created_at"]).abs < DUPLICATION_INTERVAL_IN_SECONDS
  end

private

  def fields_same?(record1, record2)
    @fields_to_compare.all? { |field| record1[field] == record2[field] }
  end
end
