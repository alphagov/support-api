require "csv"
require "anonymous_feedback_benchmark"

BENCHMARK_QUERY_STRINGS = [
  "from=2026-01-03&paths=/done/apply-blue-badge&to=2026-07-02",
  "page=3&path=/contact-jobcentre-plus&paths[]=/contact-jobcentre-plus",
  "organisation=department-for-transport&page=82",
  "organisation=driver-and-vehicle-standards-agency",
].freeze

BENCHMARK_COLUMNS = {
  "label" => :label,
  "params" => :params,
  "query" => :query,
  "run" => :run,
  "execution (ms)" => :execution,
  "shared hit" => :shared_hit,
  "shared read" => :shared_read,
  "scan" => :scan,
  "live tuples" => :live_tuples,
  "dead tuples" => :dead_tuples,
  "heap bytes" => :heap_bytes,
}.freeze

namespace :anonymous_feedback do
  desc "Benchmark the feedback queries for one named run"
  task :benchmark, [:label] => :environment do |_task, args|
    label = args[:label] ||
      abort('usage: bundle exec rake "anonymous_feedback:benchmark[my_label]"')

    benchmark = AnonymousFeedbackBenchmark.new(BENCHMARK_QUERY_STRINGS)
    ActiveRecord::Base.connection.execute("SET statement_timeout = '60s'")

    benchmark.wait_for_vacuums { |count| puts "Waiting for #{count} vacuum(s)" }
    benchmark.refresh_statistics
    stats = benchmark.table_stats

    rows = benchmark.run(label, stats) do |row|
      puts "#{row[:params]} | #{row[:query]} | run #{row[:run]} | #{row[:execution]}ms"
    end

    path = "anonymous_feedback_benchmark_#{label}.csv"
    CSV.open(path, "w") do |csv|
      csv << BENCHMARK_COLUMNS.keys
      rows.each { |row| csv << BENCHMARK_COLUMNS.values.map { |column| row[column] } }
    end

    puts "Wrote #{rows.size} measurements to #{path}"
    puts "#{stats[:live_tuples]} rows, heap #{stats[:heap_bytes] / 1024 / 1024}MB"
  end
end
