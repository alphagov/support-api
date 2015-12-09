class ContentAPILookup
  def initialize(content_api)
    @content_api = content_api
  end

  def lookup(path)
    response = api_response(path)
    ContentItem.new(path: URI(response["web_url"]).path, organisations: organisations_from(response)) if response
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
    org_tags.map { |tag|
      org_info = {
        content_id: tag["content_id"],
        slug: tag["slug"],
        web_url: tag["web_url"],
        title: tag["title"],
      }
      Organisation.create_with(org_info).find_or_create_by(content_id: org_info[:content_id])
    }
  end

  def api_response(path)
    slug = path[1..-1] # the content API expects "vat-rates" instead of "/vat-rates"
    return nil if slug.nil? || slug.empty?
    @content_api.artefact(slug)
  end
end
