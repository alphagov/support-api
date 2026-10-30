#!/usr/bin/env ruby

# Compares benchmark runs produced by `rake anonymous_feedback:benchmark`:
#
#   script/compare_anonymous_feedback_benchmarks.rb before_label after_label
#
# Defaults to run 1 of each query. Set RUN to a different number to override,
# e.g. RUN=3.

require "csv"

COMPARISONS = [
  ["Blocks read from disk", ->(row) { row["shared read"] }],
  ["Total blocks touched", ->(row) { row["shared hit"].to_i + row["shared read"].to_i }],
  ["Execution time (ms)", ->(row) { row["execution (ms)"] }],
  ["Scan type", ->(row) { row["scan"] }],
].freeze

def measurements(label, run)
  path = "anonymous_feedback_benchmark_#{label}.csv"
  abort "#{path} does not exist" unless File.file?(path)

  # rubocop:disable Rails/IndexBy
  CSV.read(path, headers: true)
     .select { |row| row["run"] == run }
     .to_h { |row| [row.values_at("params", "query"), row] }
  # rubocop:enable Rails/IndexBy
end

def print_table(headings, rows)
  widths = headings.each_index.map do |column|
    [headings, *rows].map { |row| row[column].to_s.length }.max
  end

  [headings, *rows].each do |row|
    cells = row.each_with_index.map do |cell, column|
      if cell.to_s.match?(/\A[\d.]+\z/)
        cell.to_s.rjust(widths[column])
      else
        cell.to_s.ljust(widths[column])
      end
    end

    puts cells.join("  ").rstrip
  end
end

run = ENV.fetch("RUN", "1")
labels = ARGV
abort "usage: #{$PROGRAM_NAME} before_label after_label" if labels.size < 2

by_label = labels.to_h { |label| [label, measurements(label, run)] } # rubocop:disable Rails/IndexWith
queries = by_label.values.flat_map(&:keys).uniq

puts "Table state", ""
print_table(
  ["run", "rows", "heap (MB)"],
  labels.map do |label|
    state = by_label[label].values.first
    [label, state["live tuples"], state["heap bytes"].to_i / 1024 / 1024]
  end,
)

COMPARISONS.each do |title, metric|
  puts "", "#{title}, run #{run}", ""

  print_table(
    ["query string", "query", *labels],
    queries.map do |key|
      values = labels.map do |label|
        row = by_label[label][key]
        row ? metric.call(row) : "-"
      end

      [*key, *values]
    end,
  )
end
