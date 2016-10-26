class ContentAPILookup
  def initialize(content_api)
    @content_api = content_api
  end

  def lookup(path)
    response = api_response(path)

    LookedUpContentItem.new(
      path: URI(response['web_url']).path,
      organisations: organisations_from(response),
    ) if response.present?
  end

  def organisations_from(response)
    if response["tags"]
      orgs_from_tags(response["tags"])
    else
      []
    end
  end

private
  def orgs_from_tags(tags)
    org_tags = tags.select {|t| t["details"]["type"] == "organisation" }
    org_tags.map do |tag|
      {
        content_id: tag["content_id"],
        slug: tag["slug"],
        web_url: tag["web_url"],
        title: tag["title"],
      }
    end
  end

  def api_response(path)
    slug = path[1..-1] # the content API expects "vat-rates" instead of "/vat-rates"
    return nil if slug.nil? || slug.empty?

    begin
      @content_api.artefact(slug)
    rescue GdsApi::HTTPNotFound, GdsApi::HTTPGone
      nil
    end
  end
end
