class ChangeUserAgentDatatype < ActiveRecord::Migration
  def change
    change_column :anonymous_contacts, :user_agent, :text
  end
end
