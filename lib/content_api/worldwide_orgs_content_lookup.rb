require 'content_api/base_info_lookup'

module ContentAPI
  class WorldwideOrgsContentLookup
    def applies?(path)
      path =~ %r{^/government/world/organisations}
    end

    def organisations_for(path)
      case path
      when /dfid/ then
        [{
          slug: "department-for-international-development",
          web_url: "https://www.gov.uk/government/organisations/department-for-international-development",
          title: "Department for International Development",
        }]
      when /uk-trade-investment/ then
        [{
          slug: "uk-trade-investment",
          web_url: "https://www.gov.uk/government/organisations/uk-trade-investment",
          title: "UK Trade & Investment",
        }]
      else
        [{
          slug: "foreign-commonwealth-office",
          web_url: "https://www.gov.uk/government/organisations/foreign-commonwealth-office",
          title: "Foreign & Commonwealth Office",
        }]
      end
    end

    def content_item_path(path)
      path
    end
  end
end
