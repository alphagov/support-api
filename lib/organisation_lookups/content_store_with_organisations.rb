module OrganisationLookups
  class ContentStoreWithOrganisations
    def initialize(content_store)
      @content_store = content_store
    end

    def organisations_for(path)
      response = @content_store.content_item(path)
      if response && organisation?(response)
        [{
          slug: response["base_path"].split("/").last,
          web_url: Plek.new.website_root + response["base_path"],
          title: response["title"],
        }]
      else
        []
      end
    end

  private
    def organisation?(response)
      response["format"].gsub("placeholder_", "") == "organisation"
    end
  end
end
