require 'organisation_lookups/base_info_lookup'
require 'organisation_lookups/content_store_with_organisations'

module OrganisationLookups
  class OrgsContentLookup
    def initialize(content_store)
      @content_store_with_orgs = ContentStoreWithOrganisations.new(content_store)
    end

    def applies?(path)
      path =~ %r{^/government/organisations/.+}
    end

    def organisations_for(path)
      path_to_lookup = content_item_path(path)
      @content_store_with_orgs.organisations_for(path_to_lookup)
    end

    def content_item_path(path)
      URI(path).path.split("/")[0..3].join("/")
    end
  end
end
