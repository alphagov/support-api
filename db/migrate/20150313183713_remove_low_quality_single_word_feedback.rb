class RemoveLowQualitySingleWordFeedback < ActiveRecord::Migration
  class Support::Requests::Anonymous::ProblemReport; end

  def up
    Support::Requests::Anonymous::ProblemReport.
      where.not("what_doing like '% %'").
      where.not("what_wrong like '% %'").
      update_all("is_actionable = '0', reason_why_not_actionable = 'low-quality single-word feedback'")
  end

  def down
  end
end
