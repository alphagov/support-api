require "old_feedback_deleter"

namespace :old_feedback do
  desc "Delete feedback older than 2 years, keeping aggregated service feedback"
  task delete: :environment do
    types = %w[LongFormContact ProblemReport ServiceFeedback]

    OldFeedbackDeleter.new(types:).delete { |line| puts line }
  end

  desc "Delete feedback older than 2 years, including aggregated service feedback"
  task delete_including_aggregates: :environment do
    types = %w[AggregatedServiceFeedback LongFormContact ProblemReport ServiceFeedback]

    OldFeedbackDeleter.new(types:).delete { |line| puts line }
  end
end
