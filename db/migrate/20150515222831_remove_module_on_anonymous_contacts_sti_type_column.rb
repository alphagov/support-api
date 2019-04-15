class RemoveModuleOnAnonymousContactsStiTypeColumn < ActiveRecord::Migration[4.2]
  def up
    execute "UPDATE anonymous_contacts SET type = REPLACE(type, 'Support::Requests::Anonymous::', '')"
  end
end
