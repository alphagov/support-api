# Support API

This API:

- accepts and stores GOV.UK-related requests from the public (end-users) and from departmental users
- manages anonymous feedback raised on GOV.UK

This is a Rails 5 application.

## Specs

To run the specs, execute:

    bundle exec rake

## Organisations

This app keeps a local copy of Organisations from Whitehall in the `organisations` table. In order
to populate this in your development environment:

1. Ensure whitehall is running: `bowl whitehall`
2. Run the rake task `rake api_sync:import_organisations`

## Data

When [replicating data](https://github.gds/gds/development#8-import-production-data), by default the anonymous feedback is not imported. You will have to import it by going into development and running `./sync-postgresql.sh -r -s -d backups/YYYY-MM-DD postgresql-primary-1.backend.integration`, where the date corresponds to the date of your latest backup.
