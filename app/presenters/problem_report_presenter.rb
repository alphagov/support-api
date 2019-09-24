require "plek"

class ProblemReportPresenter
  include ActionView::Helpers

  def initialize(problem_report)
    @problem_report = problem_report
  end

  def self.header_row
    ["where feedback was left", "creation date", "feedback", "user came from"]
  end

  def to_a
    [
      Plek.new.website_root + @problem_report.path,
      @problem_report.created_at.strftime("%Y-%m-%d"),
      formatted_feedback,
      @problem_report.referrer,
    ]
  end

  private
  def formatted_feedback
    [
      word_wrap("action: #{@problem_report["what_doing"]}"),
      word_wrap("problem: #{@problem_report["what_wrong"]}")
    ].join("\n")
  end
end
