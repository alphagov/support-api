class AddIndexToContentItemsOrganisationsOrganisationId < ActiveRecord::Migration[5.0]
  def change
    add_index :content_items_organisations, :organisation_id
  end
end
