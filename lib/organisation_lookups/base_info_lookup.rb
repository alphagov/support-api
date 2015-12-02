require 'organisation_lookups/content_api_with_organisations'

module OrganisationLookups
  class BaseInfoLookup
    def initialize(content_api)
      @content_api_with_orgs = ContentAPIWithOrganisations.new(content_api)
    end

    def applies?(path)
      false
    end

    def organisations_for(path)
      @content_api_with_orgs.organisations_for(path_of_parent_content_item(path))
    end
  end
end
