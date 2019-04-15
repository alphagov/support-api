class MakeOrganisationContentIdsNotNull < ActiveRecord::Migration[4.2]
  def change
    change_column :organisations, :content_id, :string, limit: 255, null: false
  end
end
