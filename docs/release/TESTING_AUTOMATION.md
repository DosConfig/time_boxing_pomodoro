# Testing Automation

Status: Mockito and Patrol are wired into the project. CircleCI is configured
for fast Linux quality checks, not iOS distribution.

## Melos

Melos owns the shared local and CI command surface. The project is still a
single Flutter app, but the root app is configured as the workspace package so
the same scripts can be used locally, in CircleCI, and in Codemagic.

Run:

```bash
dart run melos run codegen
dart run melos run analyze
dart run melos run test
dart run melos run guard
```

## Mockito

Mockito is used for generated mock tests around repository contracts.

Current coverage:

- `CalendarRepositoryImpl` stores exported TimeBox-event mappings only after a
  successful provider export.
- Denied Google Calendar export does not write local event mappings.
- `GoogleCalendarRestClient` sends Google Calendar event creation through Dio
  with bearer authorization and the expected event payload.

Run:

```bash
dart run melos run codegen
dart run melos run test
```

Generated mock files are committed so normal `flutter test` works without
regenerating first.

## Patrol

Patrol is configured for native/device smoke tests.

Current test:

```text
integration_test/app_smoke_test.dart
```

It verifies that the app launches and first-run onboarding advances. This is
intentionally small because login, notification permission, calendar permission,
and Live Activity flows require real device/simulator state and credentials.

Run locally:

```bash
dart pub global activate patrol_cli
bash scripts/test/run_patrol_smoke.sh
```

Use Patrol for:

- First launch smoke
- Onboarding navigation
- Auth screen presence
- Native permission dialogs
- Notification/Live Activity smoke on real iOS devices

Do not put full calendar provider OAuth or App Store credentials into Patrol
tests in the public repository.

## CircleCI

CircleCI is configured in:

```text
.circleci/config.yml
```

It runs:

- `flutter pub get`
- `dart run melos run codegen`
- `dart run melos run guard`

The config installs the same Flutter revision currently used locally:

```text
ad70ec4617
```

CircleCI should stay focused on pull request quality. iOS signing and TestFlight
upload remain in Codemagic/Fastlane because they require macOS signing assets
and App Store Connect credentials.

## CI Split

- CircleCI: analyze, tests, codegen, public-repo guardrails
- Codemagic: signed iOS IPA and TestFlight
- Fastlane: local or CI TestFlight/metadata lanes
- Patrol: manual or dedicated device workflow smoke tests
- Dio: Google Calendar REST event creation after Google Sign-In authorization

## References

- Mockito package: https://pub.dev/packages/mockito
- Patrol docs: https://patrol.leancode.co/
- CircleCI configuration reference: https://circleci.com/docs/configuration-reference/
