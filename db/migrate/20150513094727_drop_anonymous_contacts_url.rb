class DropAnonymousContactsUrl < ActiveRecord::Migration[4.2]
  def change
    remove_column :anonymous_contacts, :url
  end
end
