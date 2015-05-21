class AddIndexToAnonymousContactsOnCreatedAt < ActiveRecord::Migration
  def change
  	add_index "anonymous_contacts", ["created_at"], name: "index_anonymous_contacts_on_created_at", using: :btree
  end
end
