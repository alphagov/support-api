class ReplaceEmptyPaths < ActiveRecord::Migration
  class ProblemReport < ActiveRecord::Base; end

  def up
    Support::Requests::Anonymous::ProblemReport.where(path: "").update_all(path: "/")
  end

  def down
  end

end
