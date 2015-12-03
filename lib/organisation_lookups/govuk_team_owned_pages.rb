require 'organisation_lookups/content_api_lookup'

module OrganisationLookups
  class GOVUKTeamOwnedPages
    def applies?(path)
      path =~ %r{(^/$|^/browse|^/contact($|/)|^/search|^/help($|/))}
    end

    def organisations_for(path)
      [{
        slug: "government-digital-service",
        web_url: "https://www.gov.uk/government/organisations/government-digital-service",
        title: "Government Digital Service",
      }]
    end

    def path_of_parent_content_item(path)
      path
    end
  end
end
