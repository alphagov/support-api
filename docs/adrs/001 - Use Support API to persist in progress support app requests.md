# ADR001 Use Support API to persist in progress Support App Request data

## Status

Accepted

## Context

Some of the forms in the support app are long, and some serve multiple purposes.  This means they are either:
 - very broadly scoped and so do not capture the required detail to action a user's request (resulting in lots of follow-up work to get the necessary info from the requester)
 - long and difficult to complete

To fix these issues, branching and multistep forms are being introduced using the [DfE's Wizard gem](https://github.com/DFE-Digital/dfe-wizard).  This introduces a requirement for a user's answers to be temporarily persisted as they progress through a form.  The Support App has no persistence mechanism beyond a cookie backed session and in-memory caches.

## Decision

Create three new endpoints (`GET`, `PUT`, `DELETE`) in the Support API to persist and remove the in-progress form data.

## Consequences

Positives:
- Ease of implementation - this is a well-trodden path and the Support API is well developed as a backing service to the Support App
- No additional maintenance burden or cost - this approach to persistence doesn't introduce any new dependencies to the Support App or the Support API

Negatives:
- Conceptual overlap between a new `DraftSupportRequest` (or similar) object and a `SupportTicket` object (the latter already exists in the Support API).  This doesn't seem too significant at this stage but is worth bearing in mind.  There is scope in future work to refactor existing support ticket flows to introduce a `status` property and handle `draft` and `submitted` tickets differently.  This would require some initial discovery work and is currently out of scope.

## Options considered and not chosen

### Use the cookie backed session in the Support App

Positives:
 - Ease of implementation
 - Conceptually simple
 - Out of the box feature of DfE Wizard gem

Negatives:
 - Size of available storage is not sufficient (we currently don't know how long some forms will be or how much data we will need to gather from users)

### Introduce permanent persistence to the Support App (eg a redis or pg instance)

Positives:
 - Better separation of concerns

Negatives:
 - Disproportionate additional development and infrastructure configuration work
 - Significant additional maintenance burden for content-apis team
 - Additional cost of new db or redis instance
