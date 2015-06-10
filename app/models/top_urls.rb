class TopUrls
  NUMBER_OF_PATHS_PER_ORG = 5

  def initialize(first_day_of_period, period_in_question)
    @first_day_of_period = first_day_of_period
    @period_in_question = period_in_question
  end

  def to_a
    top_urls = distinct_org_acronyms.inject([]) do |list, org_acronym|
      list + top_urls_for(org_acronym).zip(1..NUMBER_OF_PATHS_PER_ORG)
    end
    top_urls.map do |top_url, rank|
      {
        "_id" => top_url_id_for(top_url.page_owner, rank),
        "_timestamp" => @first_day_of_period.to_time.iso8601,
        "period" => "month",
        "organisation_acronym" => top_url.page_owner,
        "comment_count" => top_url.number_of_paths,
        "url" => Plek.new.website_root + top_url.path
      }
    end
  end

  private
  def top_urls_for(org_acronym)
    ProblemReport.
      only_actionable.
      where(created_at: @period_in_question).
      where(page_owner: org_acronym).
      select("page_owner, path, count(*) as number_of_paths").
      group(:path, :page_owner).
      order("number_of_paths desc, path asc").
      limit(NUMBER_OF_PATHS_PER_ORG)
  end

  def distinct_org_acronyms
    ProblemReport.
      only_actionable.
      with_known_page_owner.
      order("page_owner asc").
      select(:page_owner).
      uniq.
      map(&:page_owner)
  end

  def top_url_id_for(page_owner, rank)
    "#{@first_day_of_period.strftime("%Y%m")}_#{page_owner}_#{rank}"
  end
end
