module OrganisationLookups
  class BaseInfoLookup
    def initialize(content_api)
      @content_api = content_api
    end

    def applies?(path)
      false
    end

    def organisations_for(path)
      path = content_item_api_path(path)
      response = api_response(path)

      if response && response["tags"]
        orgs_from_tags(response["tags"])
      else
        []
      end
    end

    private
    def content_item_api_path(path)
      raise "should be implemented in the subclass"
    end

    def orgs_from_tags(tags)
      org_tags = tags.select {|t| t["details"]["type"] == "organisation" }
      org_tags.map { |tag| { slug: tag["slug"], web_url: tag["web_url"], title: tag["title"] } }
    end

    def api_response(api_path)
      slug = api_path[1..-1] # the content API expects "vat-rates" instead of "/vat-rates"
      @content_api.artefact(slug)
    end
  end
end
