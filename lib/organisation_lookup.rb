require 'uri'

require 'organisation_lookups/departments_and_policy_pages'
require 'organisation_lookups/govuk_team_owned_pages'
require 'organisation_lookups/mainstream_pages'
require 'organisation_lookups/organisation_pages'
require 'organisation_lookups/worldwide_organisation_pages'
require 'organisation_lookups/catchall_assign_to_gds'

class OrganisationLookup
  def initialize(content_api, content_store)
    @lookups = [
      OrganisationLookups::GOVUKTeamOwnedPages.new,
      OrganisationLookups::MainstreamPages.new(content_api),
      OrganisationLookups::OrganisationPages.new(content_store),
      OrganisationLookups::WorldwideOrganisationPages.new,
      OrganisationLookups::DepartmentsAndPolicyPages.new(content_api),
      OrganisationLookups::CatchallAssignToGDS.new,
    ]
  end

  def organisations_for(path)
    applicable_lookups = @lookups.select { |lookup| lookup.applies?(path) }
    applicable_lookups.each do |lookup|
      orgs = lookup.organisations_for(path)
      return orgs unless orgs.empty?
    end
    nil
  end

  def path_of_parent_content_item(path)
    lookup = @lookups.detect { |lookup| lookup.applies?(path) }
    lookup.path_of_parent_content_item(path)
  end
end
