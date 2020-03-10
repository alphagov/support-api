class CleanUpOrgWithoutContentId < ActiveRecord::Migration
  def change
    orgs_without_a_content_id = Organisation.where(content_id: nil).count
    raise "Unexpected number (#{orgs_without_a_content_id}) of organisations without a content_id" if orgs_without_a_content_id > 1

    old_org = Organisation.find_by(slug: "schools-commissioner")
    new_org = Organisation.find_by(slug: "schools-commissioners-group")
    if old_org && new_org
      old_org.content_items.each do |item|
        item.organisations.delete(old_org)
        item.organisations << new_org
      end

      old_org.reload
      raise "Old org shouldn't have any content items but has #{old_org.content_items.count}" unless old_org.content_items.count == 0

      old_org.delete
    end

    orgs_without_a_content_id = Organisation.where(content_id: nil).count
    raise "There should be 0 organisations without a content_id but there are #{orgs_without_a_content_id}" if orgs_without_a_content_id > 0
  end
end
