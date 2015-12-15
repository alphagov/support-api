class ContentItemEnrichmentWorker
  include Sidekiq::Worker

  def perform(problem_report_id)
    problem_report = ProblemReport.find(problem_report_id)
    path = URI(problem_report.path).path # normalise the path before looking it up
    problem_report.content_item = fetch_content_item(path)
    problem_report.save!
  end

private
  def fetch_content_item(path)
    looked_up_item = SupportApi.content_item_lookup.lookup(path)
    if content_item = ContentItem.find_by(path: path)
      content_item.tap { |item| item.organisations = looked_up_item.organisations } # refresh the orgs
    else
      looked_up_item
    end
  end
end
