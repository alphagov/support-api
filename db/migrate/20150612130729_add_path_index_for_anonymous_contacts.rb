class AddPathIndexForAnonymousContacts < ActiveRecord::Migration
  def up
    if SupportApi.postgresql?
      execute <<-SQL
        CREATE INDEX index_anonymous_contacts_on_created_at_and_path
        ON anonymous_contacts USING btree (created_at DESC, path varchar_pattern_ops);
      SQL
    else
      add_index :anonymous_contacts, %i[created_at path], length: { path: 128 }
    end
  end

  def down
    remove_index :anonymous_contacts, %i[created_at path]
  end
end
