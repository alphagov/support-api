class ReplaceEmptyPaths < ActiveRecord::Migration
  class ProblemReport < ApplicationRecord; end

  def up
    ReplaceEmptyPaths::ProblemReport.where(path: "").update_all(path: "/")
  end

  def down
  end

end
