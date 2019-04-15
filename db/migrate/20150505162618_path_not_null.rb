class PathNotNull < ActiveRecord::Migration[4.2]
  def change
    change_column :anonymous_contacts, :path, :string, limit: 2048, null: false
  end
end
