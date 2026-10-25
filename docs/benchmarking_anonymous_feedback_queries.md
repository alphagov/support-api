# Benchmarking anonymous feedback queries

Measures the anonymous feedback queries, which are a common area of performance
issues. Use this to measure the impact of changes to queries, for instance.

## Taking a measurement

```sh
bundle exec rake "anonymous_feedback:benchmark[my_label]"
```

Times both of the queries `AnonymousFeedbackController#index` runs against four
known slow query strings. The queries are:

- a count of matching feedback
- the actual page of feedback, optionally offset (by the page query param)

Writes a CSV to the working directory with the provided label suffixed, e.g.
`anonymous_feedback_benchmark_before.csv`.

**Important:** run before making any destructive changes, then again afterwards.
Without a baseline benchmark, it's difficult to draw conclusions about the
impact of changes.

## Comparing measurements

With the CSVs from the benchmark Rake task available in the local working
directory as `anonymous_feedback_benchmark_before.csv` and
`anonymous_feedback_benchmark_after.csv` (see
[working with CSVs](https://docs.publishing.service.gov.uk/manual/running-rake-tasks.html#working-with-csvs-on-kubernetes)
for how to copy files over from deployed environments):

```sh
script/compare_anonymous_feedback_benchmarks.rb before after
```

Prints a comparison of the measurements, including:

- _blocks read from disk_ - this is the main performance indicator, since having
  to fetch a lot of data from disk is what makes these queries slow
- _total blocks touched_ - how much data the query handled whether from disk or
  memory, which is useful when disk reads fall to zero
- _execution time_ - this is useful but only as secondary evidence of
  performance improvement, since it will be affected by how busy the database is
- _scan type_ - this should stay index-based

It also prints the row count and table size from each measurement. These
confirm the change took effect. For example, if [deleting and vacuuming old
feedback](deleting_old_feedback.md), the former should reduce the row count
while leaving the table the same size on disk, and the latter should shrink
the table without changing the row count. If this expectation is not met,
something went wrong and the rest of the comparison is unreliable.

The query starting `from=2026-01-03` shouldn't improve if the change only
affects feedback from before that date.

Note: by default, the benchmark runs each query three times, but the comparison
only looks at the first run. This is to avoid measuring in-memory performance,
which is unrepresentative of most real anonymous feedback queries. It's still
useful having the three runs recorded, for instance if you want to measure
whether the queries can be cached. Use an environment variable like `RUN=3` to
compare a specific run.
