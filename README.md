# Support API

This API:

- accepts and stores GOV.UK-related requests from the public (end-users) and from departmental users
- manages anonymous feedback raised on GOV.UK

This is a Rails (4) application.

## Specs

To run the specs, execute:

    bundle exec rake

## Organisations

This app keeps a local copy of Organisations from Whitehall in the `organisations` table. In order
to populate this in your development environment:

1. Ensure whitehall is running: `bowl whitehall`
2. Run the rake task `rake api_sync:import_organisations`
