class CreateDraftSupportRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :draft_support_requests do |t|
      t.jsonb :data
      t.string :support_app_reference

      t.timestamps
    end

    add_index :draft_support_requests, :support_app_reference, unique: true
  end
end
