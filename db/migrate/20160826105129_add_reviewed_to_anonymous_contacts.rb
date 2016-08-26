class AddReviewedToAnonymousContacts < ActiveRecord::Migration
  def change
    add_column :anonymous_contacts, :reviewed, :boolean, null: false, default: false
  end
end
