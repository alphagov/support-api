require 'gds_api/content_register'

class FillOrganisationContentIds < ActiveRecord::Migration[4.2]
  def up
    return if Organisation.count == 0

    content_register = GdsApi::ContentRegister.new(Plek.new.find('content-register'))
    organisation_map = Hash[content_register.entries("organisation").map do |org|
      [org["base_path"].split('/')[-1], org["content_id"]]
    end]

    Organisation.all.each do |org|
      org.update_attribute(:content_id, organisation_map[org.slug])
    end
  end
end
