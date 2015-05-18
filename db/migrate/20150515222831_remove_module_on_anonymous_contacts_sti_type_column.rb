class RemoveModuleOnAnonymousContactsStiTypeColumn < ActiveRecord::Migration
  def up
    execute "UPDATE anonymous_contacts SET type = REPLACE(type, 'Support::Requests::Anonymous::', '')"
  end
end
