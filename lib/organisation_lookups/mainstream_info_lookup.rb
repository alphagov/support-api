require 'organisation_lookups/base_info_lookup'

module OrganisationLookups
  class MainstreamInfoLookup < BaseInfoLookup
    def applies?(path)
      path !~ %r{^/government/}
    end

    def content_item_api_path(path)
      content_item_path(path)
    end

    def content_item_path(path)
      "/" + path.split("/")[1]
    end
  end
end
