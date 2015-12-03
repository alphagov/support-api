module OrganisationLookups
  class WorldwideOrganisationPages
    def applies?(path)
      path =~ %r{^/government/world/organisations}
    end

    def organisations_for(path)
      org_slug = case path
                 when /dfid/ then "department-for-international-development"
                 when /uk-trade-investment/ then "uk-trade-investment"
                 else "foreign-commonwealth-office"
                 end
      [Organisation.find_by!(slug: org_slug)]
    end

    def path_of_parent_content_item(path)
      path
    end
  end
end
