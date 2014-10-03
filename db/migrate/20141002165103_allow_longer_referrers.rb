class AllowLongerReferrers < ActiveRecord::Migration
  def change
    change_column :anonymous_contacts, :referrer, :string, limit: 2048
  end
end
