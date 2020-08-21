class AddIndexToAnonymousContactsOnCreatedAt < ActiveRecord::Migration[5.0]
  def change
    add_index "anonymous_contacts", %w[created_at], name: "index_anonymous_contacts_on_created_at", using: :btree
  end
end
