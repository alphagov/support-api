require 'organisation_lookups/base_info_lookup'

module OrganisationLookups
  class GDSOwnedContentLookup
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

    def content_item_path(path)
      path
    end
  end
end
