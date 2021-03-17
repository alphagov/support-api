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
  a 1-5 rating for what the user thought of the service.
- **Page Improvement**: Unlike other feedback types, this is not stored in the database, but instead
  is sent directly to [Zendesk][zendesk] to be handled by the GOV.UK support team.

## Technical documentation

This is a Ruby on Rails application that provides an API for storing and retrieving feedback about GOV.UK.
It has 3 main functions:

1. a write API used by the [feedback app][feedback] to store feedback
2. a read API used by the [support app][support] to read that feedback and request exports to CSV

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
- [zendesk][zendesk] - Support API sends some types of feedback to Zendesk so it can be
  acted on by the support teams directly rather than storing it in its own database.
- [postgres](https://www.postgresql.org) - Support API uses postgres as its own database
- [redis](https://redis.io/) - Support API uses [sidekiq](https://github.com/mperham/sidekiq) to process
  background jobs (like sending feedback to zendesk) and sidekiq relies on redis

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

## Licence

[MIT License](LICENCE)

[feedback]: https://github.com/alphagov/feedback
[support]: https://github.com/alphagov/support
[zendesk]: https://govuk.zendesk.com
