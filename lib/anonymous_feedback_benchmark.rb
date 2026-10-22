require "anonymous_feedback_query"

class AnonymousFeedbackBenchmark
  VACUUM_CHECK_INTERVAL = 15
  VACUUM_CLEAR_CHECKS = 3

  def initialize(query_strings, runs: 3)
    @query_strings = query_strings
    @runs = runs
  end

  def wait_for_vacuums
    clear_checks = 0

    while clear_checks < VACUUM_CLEAR_CHECKS
      running = connection.select_value("SELECT count(*) FROM pg_stat_progress_vacuum")
      clear_checks = running.zero? ? clear_checks + 1 : 0
      yield running if running.positive?
      sleep VACUUM_CHECK_INTERVAL if clear_checks < VACUUM_CLEAR_CHECKS
    end
  end

  def refresh_statistics
    connection.execute("ANALYZE anonymous_contacts")
  end

  def table_stats
    row = connection.select_one(<<~SQL.squish)
      SELECT n_live_tup, n_dead_tup, pg_relation_size('anonymous_contacts') AS heap_bytes
      FROM pg_stat_user_tables WHERE relname = 'anonymous_contacts'
    SQL

    { live_tuples: row["n_live_tup"], dead_tuples: row["n_dead_tup"], heap_bytes: row["heap_bytes"] }
  end

  def run(label, stats, &block)
    @query_strings.flat_map { |query_string| rows_for(label, query_string, stats, &block) }
  end

private

  def connection
    ActiveRecord::Base.connection
  end

  def rows_for(label, query_string, stats, &block)
    queries(query_string).flat_map do |query, sql|
      @runs.times.map do |index|
        row = { label:, params: query_string, query:, run: index + 1, **stats }
        measure(row, sql).tap(&block)
      end
    end
  end

  def queries(query_string)
    query = AnonymousFeedbackQuery.new(query_string)
    page_size = AnonymousContact::PAGE_SIZE
    count_limit = AnonymousContact::MAX_PAGES * page_size
    scope = AnonymousContact.for_query_parameters(query.options).most_recent_first
    queries = { "count" => "SELECT COUNT(*) FROM (#{scope.limit(count_limit).to_sql}) counted" }

    pages = (scope.limit(count_limit).count / page_size.to_f).ceil
    page = [query.page, 1].max
    return queries if page > pages

    queries.merge("page #{page}" => scope.offset((page - 1) * page_size).limit(page_size).to_sql)
  end

  def measure(row, sql)
    explained = ActiveRecord::Base.uncached do
      connection.select_value("EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) #{sql}")
    end
    analysis = JSON.parse(explained).first
    plan = analysis["Plan"]

    row.merge(
      execution: analysis["Execution Time"].round(1),
      shared_hit: plan["Shared Hit Blocks"],
      shared_read: plan["Shared Read Blocks"],
      scan: scan_node(plan) || plan["Node Type"],
    )
  rescue ActiveRecord::QueryCanceled
    row.merge(scan: "timed out")
  end

  def scan_node(plan)
    return plan["Node Type"] if plan["Relation Name"] == "anonymous_contacts"

    plan.fetch("Plans", []).filter_map { |child| scan_node(child) }.first
  end
end
