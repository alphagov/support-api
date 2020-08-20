class AddIndexOnAnonymousContactsPath < ActiveRecord::Migration[5.0]
  def change
    add_index "anonymous_contacts", %w[path], name: "index_anonymous_contacts_on_path", using: :btree
  end
end
