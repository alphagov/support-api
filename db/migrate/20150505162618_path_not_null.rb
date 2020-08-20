class PathNotNull < ActiveRecord::Migration[5.0]
  def change
    change_column :anonymous_contacts, :path, :string, limit: 2048, null: false
  end
end
