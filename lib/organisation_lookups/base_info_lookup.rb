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
      @content_api_with_orgs.organisations_for(content_item_api_path(path))
    end

  private
    def content_item_api_path(path)
      raise "should be implemented in the subclass"
    end
  end
end
