class AddReviewedToAnonymousContacts < ActiveRecord::Migration[4.2]
  def change
    add_column :anonymous_contacts, :reviewed, :boolean, null: false, default: false
  end
end
