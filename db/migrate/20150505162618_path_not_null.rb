class PathNotNull < ActiveRecord::Migration
  def change
    change_column :anonymous_contacts, :path, :string, limit: 2048, null: false
  end
end
