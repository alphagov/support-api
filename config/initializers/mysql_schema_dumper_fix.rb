require "active_record/connection_adapters/abstract_mysql_adapter"

# Backported fix from future Rails. Prevents MySQL's schema dumper from including the :limit
# argument for boolean field types, which breaks PostgreSQL.
# See the PR for details: https://github.com/rails/rails/pull/19066

if Rails.gem_version >= Gem::Version.new("4.2.2")
  warn "WARNING: Remove #{__FILE__}, not needed in Rails 4.2.2"
else
  module MysqlSchemaDumperFix
    def prepare_column_options(column, types)
      spec = super
      spec.delete(:limit) if :boolean === column.type
      spec
    end
  end

  ActiveRecord::ConnectionAdapters::AbstractMysqlAdapter.prepend MysqlSchemaDumperFix
end
