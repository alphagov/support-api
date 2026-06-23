class AddIndexesForSummary < ActiveRecord::Migration[8.1]
  def change
    add_index :content_items_organisations, %i[organisation_id content_item_id], name: :index_organisations_content_items, unique: true
    add_index :organisations, %i[slug id], name: :index_organisations_on_slug_id, unique: true
  end
end
