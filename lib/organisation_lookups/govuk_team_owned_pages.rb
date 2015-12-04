require 'organisation_lookups/content_api_lookup'

module OrganisationLookups
  class GOVUKTeamOwnedPages
    def applies?(path)
      path =~ %r{(^/$|^/browse|^/contact($|/)|^/search|^/help($|/))}
    end

    def organisations_for(path)
      [Organisation.find_by!(slug: "government-digital-service")]
    end

    def path_of_parent_content_item(path)
      path
    end
  end
end
