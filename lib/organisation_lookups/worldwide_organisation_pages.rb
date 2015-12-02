module OrganisationLookups
  class WorldwideOrganisationPages
    def applies?(path)
      path =~ %r{^/government/world/organisations}
    end

    def organisations_for(path)
      case path
      when /dfid/ then
        [{
          content_id: "db994552-7644-404d-a770-a2fe659c661f",
          slug: "department-for-international-development",
          web_url: "https://www.gov.uk/government/organisations/department-for-international-development",
          title: "Department for International Development",
        }]
      when /uk-trade-investment/ then
        [{
          content_id: "b045c8df-d3c4-4219-88d8-264dc9ee5cc8",
          slug: "uk-trade-investment",
          web_url: "https://www.gov.uk/government/organisations/uk-trade-investment",
          title: "UK Trade & Investment",
        }]
      else
        [{
          content_id: "9adfc4ed-9f6c-4976-a6d8-18d34356367c",
          slug: "foreign-commonwealth-office",
          web_url: "https://www.gov.uk/government/organisations/foreign-commonwealth-office",
          title: "Foreign & Commonwealth Office",
        }]
      end
    end

    def path_of_parent_content_item(path)
      path
    end
  end
end
