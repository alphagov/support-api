class AddMarkedAsSpamToAnonymousContacts < ActiveRecord::Migration[5.0]
  def change
    add_column :anonymous_contacts, :marked_as_spam, :boolean, null: false, default: false
  end
end
