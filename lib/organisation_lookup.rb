require 'uri'

require 'organisation_lookups/depts_and_policy_content_lookup'
require 'organisation_lookups/gds_owned_content_lookup'
require 'organisation_lookups/mainstream_info_lookup'
require 'organisation_lookups/orgs_content_lookup'
require 'organisation_lookups/worldwide_orgs_content_lookup'
require 'organisation_lookups/default_org_content_lookup'

class OrganisationLookup
  def initialize(content_api, content_store)
    @lookups = [
      OrganisationLookups::GDSOwnedContentLookup.new,
      OrganisationLookups::MainstreamInfoLookup.new(content_api),
      OrganisationLookups::OrgsContentLookup.new(content_store),
      OrganisationLookups::WorldwideOrgsContentLookup.new,
      OrganisationLookups::DeptsAndPolicyContentLookup.new(content_api),
      OrganisationLookups::DefaultOrgContentLookup.new,
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
