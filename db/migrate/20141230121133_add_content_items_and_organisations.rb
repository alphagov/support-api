class AddContentItemsAndOrganisations < ActiveRecord::Migration[4.2]
  def change
    create_table :content_items do |t|
      t.string "path", limit: 2048, null: false
      t.timestamps null: false
    end

    create_table :organisations do |t|
      t.string :slug, null: false
      t.string :web_url, null: false
      t.string :title, null: false
      t.timestamps null: false
    end

    create_table :content_items_organisations, id: false do |t|
      t.belongs_to :content_item, index: true
      t.belongs_to :organisation, index: true
    end

    add_column :anonymous_contacts, :content_item_id, :integer
  end
end
