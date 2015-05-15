class ContentItemEnrichmentWorker
  include Sidekiq::Worker

  def perform(problem_report_id)
    problem_report = ProblemReport.find(problem_report_id)
    problem_report.content_item = ContentItem.where(path: problem_report.content_item_path).first_or_create!
    problem_report.save!
  end
end
