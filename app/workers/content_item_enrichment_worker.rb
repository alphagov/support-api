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
    if (content_item = ContentItem.find_by(path: path))
      content_item.tap { |item| item.organisations = build_orgs(looked_up_item.organisations) } # refresh the orgs
    else
      ContentItem.new(path: looked_up_item.path, organisations: build_orgs(looked_up_item.organisations))
    end
  end

  def build_orgs(org_hashes)
    org_hashes.map do |org_data|
      Organisation.create_with(org_data).find_or_create_by(content_id: org_data[:content_id])
    end
  end
end
