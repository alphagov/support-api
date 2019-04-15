class ReplaceEmptyOrNullPaths < ActiveRecord::Migration[4.2]
  def up
    Support::Requests::Anonymous::AnonymousContact.
      unscoped.
      where("path = '' or path is null").
      update_all(path: "/")
  end

  def down
  end
end
