require "rails_helper"
require "old_feedback_deleter"

describe OldFeedbackDeleter do
  subject(:deleter) { described_class.new(types: %w[ProblemReport ServiceFeedback]) }

  let(:lines) { [] }

  def delete
    deleter.delete { |line| lines << line }
  end

  it "deletes feedback of the given types older than 2 years" do
    old_feedback = create(:problem_report, created_at: 2.years.ago - 1.day)

    delete

    expect(AnonymousContact.where(id: old_feedback.id)).not_to exist
  end

  it "keeps feedback of the given types from within the last 2 years" do
    recent_feedback = create(:problem_report, created_at: 2.years.ago + 1.day)

    delete

    expect(AnonymousContact.where(id: recent_feedback.id)).to exist
  end

  it "keeps old feedback of types it was not given" do
    other_feedback = create(:aggregated_service_feedback, created_at: 2.years.ago - 1.day)

    delete

    expect(AnonymousContact.where(id: other_feedback.id)).to exist
  end

  it "reports how much feedback it is deleting" do
    create(:problem_report, created_at: 2.years.ago - 1.day)

    delete

    expect(lines).to include("Deleting 1 anonymous contacts (feedback) older than 2 years")
  end

  it "reports the types it is deleting" do
    delete

    expect(lines).to include("Types: ProblemReport, ServiceFeedback")
  end

  it "reports its progress through the batches" do
    create(:problem_report, created_at: 2.years.ago - 1.day)

    delete

    expect(lines).to include(a_string_matching(%r{Deleted 1/1 \(100\.0%\) in \d+(\.\d+)?s}))
  end

  it "reports what remains of the given types" do
    create(:problem_report, created_at: 2.years.ago - 1.day)

    delete

    expect(lines).to include("  of the provided types: 0")
  end

  it "reports what remains across all types" do
    create(:aggregated_service_feedback, created_at: 2.years.ago - 1.day)

    delete

    expect(lines).to include("  of all types: 1")
  end
end
