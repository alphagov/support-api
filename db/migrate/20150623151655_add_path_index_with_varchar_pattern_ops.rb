class AddPathIndexWithVarcharPatternOps < ActiveRecord::Migration[4.2]
  def up
    remove_index :anonymous_contacts, :path

    if SupportApi.postgresql?
      execute <<-SQL
        CREATE INDEX index_anonymous_contacts_on_path
        ON anonymous_contacts USING btree (path varchar_pattern_ops);
      SQL
    else
      add_index :anonymous_contacts, [:path], length: {path: 128}
    end
  end

  def down
    remove_index :anonymous_contacts, [:path]
    add_index :anonymous_contacts, [:path], length: {path: 128}
  end
end
