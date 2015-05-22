class AddContentIdToOrganisations < ActiveRecord::Migration
  def change
    add_column :organisations, :content_id, :string, limit: 255
    add_index :organisations, [:content_id], name: "index_organisations_on_content_id", using: :btree
  end
end
