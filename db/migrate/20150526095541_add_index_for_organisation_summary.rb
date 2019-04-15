class AddIndexForOrganisationSummary < ActiveRecord::Migration[4.2]
  def change
    add_index :anonymous_contacts, [:content_item_id, :created_at]
  end
end
