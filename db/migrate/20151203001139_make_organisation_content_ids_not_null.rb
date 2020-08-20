class MakeOrganisationContentIdsNotNull < ActiveRecord::Migration[5.0]
  def change
    change_column :organisations, :content_id, :string, limit: 255, null: false
  end
end
