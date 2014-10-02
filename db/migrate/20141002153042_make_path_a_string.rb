class MakePathAString < ActiveRecord::Migration
  def change
    change_column :anonymous_contacts, :path, :string, limit: 2048
  end
end
