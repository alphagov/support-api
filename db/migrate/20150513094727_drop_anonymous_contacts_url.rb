class DropAnonymousContactsUrl < ActiveRecord::Migration[5.0]
  def change
    remove_column :anonymous_contacts, :url
  end
end
