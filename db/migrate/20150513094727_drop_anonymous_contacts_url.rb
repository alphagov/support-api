class DropAnonymousContactsUrl < ActiveRecord::Migration
  def change
    remove_column :anonymous_contacts, :url
  end
end
