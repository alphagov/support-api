# Deleting old feedback

## Benchmarking

**Important:** if you want to measure the impact on performance of deleting old
feedback, [benchmark](benchmarking_anonymous_feedback_queries.md) at three
stages:

- _before_ deleting any feedback
- _after_ deleting feedback but _before_ vacuuming the table
- _after_ vacuuming the table

Having benchmarks both at the baseline and after each discrete action allows you
to observe the impact of each action. Without capturing a baseline benchmark, it
would be difficult to draw any conclusions.

## Deleting the database records

```sh
bundle exec rake old_feedback:delete
```

Removes feedback older than two years in batches to avoid long locks. This
doesn't resize the table on disk - the database pages are only marked as
freed/reusable. The vacuum task will shrink the disk usage, which also affects
performance.

It keeps aggregated service feedback, which is a daily count per page of how
many people gave each rating rather than individual submissions. It holds no
personally-identifiable information, and deleting it would leave no record of
service satisfaction beyond two years. To delete it as well:

```sh
bundle exec rake old_feedback:delete_including_aggregates
```

When running on a deployed environment, pass `--stdin --tty` to `kubectl exec`
so progress appears as it happens rather than all at the end.

## Recovering disk space

```sh
bundle exec rake old_feedback:vacuum
```

When running on a deployed environment, pass `--stdin --tty` to `kubectl exec`
so progress appears as it happens rather than all at the end.

Rewrites the `anonymous_contacts` table so the space the deletion freed is
returned to the disk. This blocks every read and write to the table while it
runs, though the two aren't equally affected:

- writes go through a Sidekiq queue, so submission requests complete as usual
  and the database writes are paused rather than lost, catching up afterwards
- reads have no such buffer, so Feedback Explorer is fully offline for the
  duration

It reports how long it took, which is how long reads were unavailable for, so a
run in e.g. integration can inform whether this is acceptable in production.

It gives up if it can't get a lock within 5 seconds, leaving the table
untouched, so you may need to retry at a quieter time. While it waits for a
lock, everything arriving behind it waits too, so a longer wait would block the
table before the rewrite even starts.
