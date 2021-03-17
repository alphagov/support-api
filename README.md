# Support API

This app provides an API for storing and fetching anonymous feedback about pages on GOV.UK. Data
comes in from the [feedback app][feedback] on the public-facing frontend and is read by [the
support app][support] on the admin-facing backend. Alternatively, some types of feedback are sent
to Zendesk so it can be acted on by the support teams directly.

Support API can receive feedback about any page on GOV.UK, but all it is sent is the path.  We use the
content-store to look up extra information (content_id, associated organisations, etc) about these pages
to allow for better search and filtering of the feedback.

Support API also stores ratings for services. It aggregates those ratings every day in order to keep
the size of the database manageable - see `config/schedule.rb` for more details. Previously the aggregate
ratings were uploaded to the performance platform, which no longer exists.

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

This is a Ruby on Rails app, and should follow [our Rails app conventions](https://docs.publishing.service.gov.uk/manual/conventions-for-rails-applications.html).

You can use the [GOV.UK Docker environment](https://github.com/alphagov/govuk-docker) to run the application and its tests with all the necessary dependencies. Follow [the usage instructions](https://github.com/alphagov/govuk-docker#usage) to get started.

**Use GOV.UK Docker to run any commands that follow.**

### Running the test suite

`bundle exec rake`

## Licence

[MIT License](LICENCE)

[feedback]: https://github.com/alphagov/feedback
[support]: https://github.com/alphagov/support
[zendesk]: https://govuk.zendesk.com
