require "rails_helper"

shared_examples "an old feedback deletion task" do |task_name, expected_types|
  subject(:task) { Rake::Task[task_name] }

  let(:deleter) { instance_double(OldFeedbackDeleter) }

  before do
    task.reenable
    allow($stdout).to receive(:puts)
    allow(OldFeedbackDeleter).to receive(:new).and_return(deleter)
    allow(deleter).to receive(:delete)
  end

  it "deletes the expected types" do
    task.invoke

    expect(OldFeedbackDeleter).to have_received(:new).with(types: expected_types)
  end

  it "runs the deletion" do
    task.invoke

    expect(deleter).to have_received(:delete)
  end

  it "points at the task that reclaims the disk space" do
    task.invoke

    expect($stdout).to have_received(:puts).with(/old_feedback:vacuum/)
  end
end

describe "old_feedback:delete" do
  it_behaves_like "an old feedback deletion task",
                  "old_feedback:delete",
                  %w[LongFormContact ProblemReport ServiceFeedback]
end

describe "old_feedback:delete_including_aggregates" do
  it_behaves_like "an old feedback deletion task",
                  "old_feedback:delete_including_aggregates",
                  %w[AggregatedServiceFeedback LongFormContact ProblemReport ServiceFeedback]
end
