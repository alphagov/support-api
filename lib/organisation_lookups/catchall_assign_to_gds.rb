module OrganisationLookups
  # For any content items where the interested organisation cannot be determined,
  # it's assigned to GDS, which runs GOV.UK
  class CatchallAssignToGDS
    def applies?(path)
      true
    end

    def organisations_for(path)
      [{
        slug: "government-digital-service",
        web_url: "https://www.gov.uk/government/organisations/government-digital-service",
        title: "Government Digital Service",
      }]
    end

    def path_of_parent_content_item(path)
      path
    end
  end
end
