class ChangeUserAgentDatatype < ActiveRecord::Migration[5.0]
  def change
    change_column :anonymous_contacts, :user_agent, :text
  end
end
