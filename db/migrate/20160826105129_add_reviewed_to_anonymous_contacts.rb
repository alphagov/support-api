class AddReviewedToAnonymousContacts < ActiveRecord::Migration[5.0]
  def change
    add_column :anonymous_contacts, :reviewed, :boolean, null: false, default: false
  end
end
