class AllowLongerReferrers < ActiveRecord::Migration[4.2]
  def change
    change_column :anonymous_contacts, :referrer, :string, limit: 2048
  end
end
