require 'organisation_lookups/base_info_lookup'

module OrganisationLookups
  class DefaultOrgContentLookup
    def applies?(path)
      true
    end

    def organisations_for(path)
      [{
        slug: "government-digital-service",
        web_url: "https://www.gov.uk/government/organisations/government-digital-service",
        title: "Government Digital Service",
      }]
    end

    def content_item_path(path)
      path
    end
  end
end
