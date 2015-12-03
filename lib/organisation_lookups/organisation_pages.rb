require 'organisation_lookups/content_store_with_organisations'

module OrganisationLookups
  class OrganisationPages
    def initialize(content_store)
      @content_store_with_orgs = ContentStoreWithOrganisations.new(content_store)
    end

    def applies?(path)
      path =~ %r{^/government/organisations/.+}
    end

    def organisations_for(path)
      path_to_lookup = path_of_parent_content_item(path)
      @content_store_with_orgs.organisations_for(path_to_lookup)
    end

    def path_of_parent_content_item(path)
      URI(path).path.split("/")[0..3].join("/")
    end
  end
end
