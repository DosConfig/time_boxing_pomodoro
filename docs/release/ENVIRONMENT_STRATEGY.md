# Environment Strategy

## Decision

Use two real environments now:

- `dev`: local development, automated tests that need Firebase, and internal QA.
- `prod`: App Store/TestFlight candidate data and the public legal website.

Add `stg` only when external beta testers, subscription products, invite codes,
or server migrations need a production-like rehearsal environment. Creating
three Firebase projects before those flows exist adds credential and signing
work without improving the current app.

## Why Production-Only Is No Longer Enough

Authentication, Firestore daily plans, Google Calendar OAuth, and account
deletion now change real user data. Development against `timebox-mark-prod`
would mix test users and plans with release verification and makes destructive
tests unsafe.

## Human Setup Required For `dev`

1. Create a Firebase/GCP project such as `timebox-mark-dev` under the release
   owner account.
2. Register `com.seongwoo.focusmark.dev` for iOS and an equivalent Android
   application ID suffix.
3. Enable Apple/Google Firebase Auth providers and the Google Calendar API.
4. Add development OAuth test users and development redirect clients.
5. Generate Firebase client files locally; keep them ignored and store encoded
   CI copies only in the relevant secret manager.
6. Add development signing identifiers only after the dev bundle IDs exist in
   Apple Developer and Firebase.

## Code Change Trigger

Do not add a provider selector or fallback UI. Add Flutter flavors and separate
Firebase option entry points only after the `dev` project and bundle IDs exist,
then verify both flavors with sign-in, Firestore rules, account deletion, and
calendar OAuth. Production remains the default release flavor.

## Staging Trigger

Create `stg` before the first workflow that includes any of the following:

- external TestFlight/Play beta using nonproduction data,
- paid subscriptions or entitlement migrations,
- invite-code Cloud Functions,
- watch/device pairing backed by server state,
- Firestore schema or rules migrations requiring rehearsal.
