# Support API

This app provides an API for storing and fetching anonymous feedback about pages on GOV.UK.  Data
comes in from the [feedback app][feedback] on the public-facing frontend and is read by [the
support app][support] on the admin-facing backend.

## Nomenclature

- **Feedback**: Everything stored in the app is considered to be "feedback" of some form or other and
  relates to pages published on GOV.UK.  Confusingly most of the data also comes from the [feedback
  app][feedback], but when we talk about feedback in the context of the support-api we don't usually
  mean the feedback app, we mean the data stored in the database.
- **Anonymous Contact**: All feedback stored in this app is anonymous.  This is in contrast with the
  `Named Contact` feedback that is sent directly to the [support app][support].  All feedback in this
  app is scanned to see if it may contain Personally Identifiable Information (PII) and flagged if we
  think it might.
- **Service Feedback**: This is feedback that came from the short survey on a "done" page and contains
  a 1-5 rating for what the user thought of the service.  These ratings are aggregated and sent to the
  [performance platform][performance-platform] so that it can appear in the performance details as
  user satisfaction of those services.
- **Page Improvement**: Unlike other feedback types, this is not stored in the database, but instead
  is sent directly to [Zendesk][zendesk] to be handled by the GOV.UK support team.

## Technical documentation

This is a Ruby on Rails application that provides an API for storing and retrieving feedback about GOV.UK.
It has 3 main functions:

1. a write API used by the [feedback app][feedback] to store feedback
2. a read API used by the [support app][support] to read that feedback and request exports to CSV
3. a background job used to aggregate service feedback and write it to the [performance
   platform][performance-platform]

### CSV exports
When a CSV export is requested by the support app, a CSV file is generated and saved in Amazon S3.

### Dependencies

- [content-store](https://github.com/alphagov/content-store) - Support API can receive feedback about any
  page on GOV.UK, but all it is sent is the path.  We use the content-store to look up extra information
  (content_id, associated organisations, etc) about these pages to allow for better search and filtering
  of the feedback.
- [whitehall](https://github.com/alphagov/whitehall) - Support API has a table of Organisations and as
  Whitehall is the canonical source of that information we use its Organisations API to keep our data up
  to date.
- [performance platform][performance-platform] - Support API stores ratings for services.
  It aggregates those ratings every day and writes that data to the performance platform write API.  We
  can also use the performance platform read API to import those ratings if there's ever a discrepancy.
- [zendesk][zendesk] - Support API sends some types of feedback to Zendesk so it can be
  acted on by the support teams directly rather than storing it in its own database.
- [postgres](https://www.postgresql.org) - Support API uses postgres as its own database
- [redis](https://redis.io/) - Support API uses [sidekiq](https://github.com/mperham/sidekiq) to process
  background jobs (like sending feedback to zendesk, or aggregating feedback and sending it to the
  performance platform) and sidekiq relies on redis

### Running the application

`./startup.sh`

This will install any dependencies via [`bundler`](https://bundler.io) and then run the app.  It listens on
port 3075 and if run via the [GOV.UK Dev VM](https://docs.publishing.service.gov.uk/manual/get-started.html)
will be available at http://support-api.dev.gov.uk (although as an API it has no UI pages for you to visit).

### Running the test suite

`bundle exec rake`

This will run the [rspec test suite](spec) and generate a coverage report for these specs in `./coverage`.

### Organisations

This app keeps a local copy of Organisations from Whitehall in the `organisations` table. In order
to keep this up-to-date it runs a sync job overnight via cron.  To run the same script on your local
development environment do the following:

1. Ensure whitehall is running: `bowl whitehall`
2. Run the rake task `rake api_sync:import_organisations`

You most likely will only need to do this if your whitehall data is more recent than your data for
this app.

### Getting Data

When [replicating data](https://docs.publishing.service.gov.uk/manual/replicate-app-data-locally.html) into
your dev VM the database for the support-api is one of the ones ignored by default because it's quite large.
To get this data you will have to explicitly request to import it by running:

`./sync-postgresql.sh -r -s -d backups/YYYY-MM-DD postgresql-primary-1.backend.integration`

Replacing `YYYY-MM-DD` with the date of your latest backup.  Note that this may take some time as it will
re-import all the postgres databases that come from that server.  You may wish to explore [other arguments
to the replication scripts](https://github.com/alphagov/govuk-puppet/blob/master/development-vm/replication/common-args.sh)
which will allow you to filter out other databases from that server.

## Licence

[MIT License](LICENCE)

[feedback]: https://github.com/alphagov/feedback
[support]: https://github.com/alphagov/support
[performance-platform]: https://github.com/alphagov/backdrop
[zendesk]: https://govuk.zendesk.com
