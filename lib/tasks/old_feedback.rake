require "old_feedback_deleter"

namespace :old_feedback do
  desc "Delete feedback older than 2 years, keeping aggregated service feedback"
  task delete: :environment do
    types = %w[LongFormContact ProblemReport ServiceFeedback]

    OldFeedbackDeleter.new(types:).delete { |line| puts line }
    puts "Run old_feedback:vacuum to shrink the table on disk"
  end

  desc "Delete feedback older than 2 years, including aggregated service feedback"
  task delete_including_aggregates: :environment do
    types = %w[AggregatedServiceFeedback LongFormContact ProblemReport ServiceFeedback]

    OldFeedbackDeleter.new(types:).delete { |line| puts line }
    puts "Run old_feedback:vacuum to shrink the table on disk"
  end

  desc "Shrink anonymous_contacts on disk after old_feedback:delete"
  task vacuum: :environment do
    connection = ActiveRecord::Base.connection
    heap_size_query = "SELECT pg_size_pretty(pg_relation_size('anonymous_contacts'))"

    puts "Shrinking anonymous_contacts (#{connection.select_value(heap_size_query)}), " \
         "blocking all reads and writes until it finishes"

    started = Time.zone.now
    connection.execute("SET lock_timeout = '5s'")
    connection.execute("SET statement_timeout = 0")
    connection.execute("VACUUM (FULL, ANALYZE) anonymous_contacts")
    elapsed = (Time.zone.now - started).round(1)

    puts "Shrank to #{connection.select_value(heap_size_query)}, blocked for #{elapsed}s"
  rescue ActiveRecord::LockWaitTimeout
    abort "Couldn't get a lock within 5s so the vacuum was not run - " \
          "try again when the database is quieter"
  end
end
