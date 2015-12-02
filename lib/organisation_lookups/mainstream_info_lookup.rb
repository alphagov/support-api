require 'organisation_lookups/content_api_lookup'

module OrganisationLookups
  class MainstreamInfoLookup < ContentAPILookup
    def applies?(path)
      path !~ %r{^/government/}
    end

    def path_of_parent_content_item(path)
      "/" + path.split("/")[1]
    end
  end
end
