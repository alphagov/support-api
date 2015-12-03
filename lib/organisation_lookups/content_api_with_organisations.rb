module OrganisationLookups
  class ContentAPIWithOrganisations
    def initialize(content_api)
      @content_api = content_api
    end

    def organisations_for(path)
      response = api_response(path)

      if response && response["tags"]
        orgs_from_tags(response["tags"])
      else
        []
      end
    end

  private
    def orgs_from_tags(tags)
      org_tags = tags.select {|t| t["details"]["type"] == "organisation" }
      org_tags.map { |tag|
        {
          content_id: tag["content_id"],
          slug: tag["slug"],
          web_url: tag["web_url"],
          title: tag["title"],
        }
      }
    end

    def api_response(api_path)
      slug = api_path[1..-1] # the content API expects "vat-rates" instead of "/vat-rates"
      @content_api.artefact(slug)
    end
  end
end
