module OrganisationLookups
  # For any content items where the interested organisation cannot be determined,
  # it's assigned to GDS, which runs GOV.UK
  class CatchallAssignToGDS
    def applies?(path)
      true
    end

    def organisations_for(path)
      [Organisation.find_by!(slug: "government-digital-service")]
    end

    def path_of_parent_content_item(path)
      path
    end
  end
end
