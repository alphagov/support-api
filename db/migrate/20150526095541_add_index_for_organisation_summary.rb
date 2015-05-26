class AddIndexForOrganisationSummary < ActiveRecord::Migration
  def change
    add_index :anonymous_contacts, [:content_item_id, :created_at]
  end
end
