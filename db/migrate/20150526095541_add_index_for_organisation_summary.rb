class AddIndexForOrganisationSummary < ActiveRecord::Migration[5.0]
  def change
    add_index :anonymous_contacts, %i[content_item_id created_at]
  end
end
