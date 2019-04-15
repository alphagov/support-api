class ChangeUserAgentDatatype < ActiveRecord::Migration[4.2]
  def change
    change_column :anonymous_contacts, :user_agent, :text
  end
end
