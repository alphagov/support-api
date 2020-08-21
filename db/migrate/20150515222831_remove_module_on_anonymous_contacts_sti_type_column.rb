class RemoveModuleOnAnonymousContactsStiTypeColumn < ActiveRecord::Migration[5.0]
  def up
    execute "UPDATE anonymous_contacts SET type = REPLACE(type, 'Support::Requests::Anonymous::', '')"
  end
end
