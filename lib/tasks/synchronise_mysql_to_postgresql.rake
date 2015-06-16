task "db:sync" do
  BATCH_SIZE = 2500

  mysql = Sequel.connect(ActiveRecord::Base.configurations["mysql_#{Rails.env}"])
  postgresql = Sequel.connect(ActiveRecord::Base.configurations["postgresql_#{Rails.env}"])

  # Exclude schema_migrations as it's managed by migrations, and content_items_organisations as it's
  # a join table.
  tables = ActiveRecord::Base.connection.tables - ["schema_migrations", "content_items_organisations"]

  tables.each do |table|
    mysql_class = mysql[table.to_sym]
    postgresql_class = postgresql[table.to_sym]

    progress = ProgressBar.create(title: table,
                                  starting_at: postgresql_class.max(:id).to_i,
                                  total: mysql_class.max(:id).to_i,
                                  length: 100,
                                  format: "%t: %c/%C |%B| %E",
                                  throttle_rate: 0.1)

    while (postgresql_class.max(:id) || 0) < mysql_class.max(:id) do
      res = mysql_class.filter('id > ?', postgresql_class.max(:id) || 0).order(:id).limit(BATCH_SIZE).all
      postgresql_class.multi_insert(res)
      progress.progress += BATCH_SIZE if progress.progress + BATCH_SIZE < progress.total
    end
    progress.finish
  end

  # As content_items_organisations is a join table, it's best to just find all rows from mysql
  # that aren't in postgresql and insert them. There's only ~8000 rows
  missing = mysql[:content_items_organisations].all.to_set -
            postgresql[:content_items_organisations].all.to_set

  postgresql[:content_items_organisations].multi_insert(missing)
end
