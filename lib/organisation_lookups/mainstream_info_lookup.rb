require 'organisation_lookups/base_info_lookup'

module OrganisationLookups
  class MainstreamInfoLookup < BaseInfoLookup
    def applies?(path)
      path !~ %r{^/government/}
    end

    def path_of_parent_content_item(path)
      "/" + path.split("/")[1]
    end
  end
end
