# Release Automation

Status: Fastlane and Codemagic configuration added. Shorebird is initialized;
Codemagic creates patchable iOS releases and keeps patches manually triggered.

## Current Status

- Firebase Hosting legal pages are live at `https://timebox-mark-prod.web.app`.
- Fastlane lanes are defined under `ios/fastlane`.
- Codemagic workflows are defined in `codemagic.yaml`.
- CircleCI quality workflow is defined in `.circleci/config.yml`.
- Melos scripts are defined in the root `pubspec.yaml` and are used by both
  CircleCI and Codemagic for code generation and guardrails.
- Ignored Firebase client files are restored in CI from base64 environment
  variables.
- Secret-like tracked files are blocked by `scripts/ci/verify_release_guardrails.sh`.
- Shorebird release and patch workflows require the encrypted
  `SHOREBIRD_TOKEN` in Codemagic.

## Required Secrets

Set these locally in `.env` or in Codemagic environment group
`timebox_mark_ios_release`:

```text
APP_IDENTIFIER=com.seongwoo.focusmark
APPLE_ID=seongwoo@10xkeleton.com
APPLE_TEAM_ID=HC9DTZBGLT
APP_STORE_CONNECT_TEAM_ID=22759746113
APP_STORE_CONNECT_KEY_ID=
APP_STORE_CONNECT_ISSUER_ID=
APP_STORE_CONNECT_KEY_FILEPATH=
APP_STORE_CONNECT_KEY_CONTENT=
APP_STORE_CONNECT_KEY_CONTENT_BASE64=false
FIREBASE_OPTIONS_DART_BASE64=
GOOGLE_SERVICE_INFO_PLIST_BASE64=
GOOGLE_SERVICES_JSON_BASE64=
GOOGLE_REVERSED_CLIENT_ID=
```

Account mapping:

- App Store Connect login/contact: `seongwoo@10xkeleton.com`
- App Store Connect team/provider: `SEONGWOO DO|22759746113|1`
- Apple Developer Portal Team ID: `HC9DTZBGLT`

Do not replace `APPLE_TEAM_ID` with the email address. Xcode signing requires
the 10-character Developer Team ID.

For Codemagic, create an App Store Connect integration named:

```text
timebox_mark_app_store_connect
```

## Fastlane

Install:

```bash
bundle install
```

Verify locally:

```bash
cd ios
bundle exec fastlane ios verify
```

Build a signed IPA:

```bash
cd ios
bundle exec fastlane ios build_ipa
```

Upload to TestFlight:

```bash
cd ios
bundle exec fastlane ios internal_beta
```

Upload metadata only:

```bash
cd ios
bundle exec fastlane ios metadata
```

Fastlane uploads to TestFlight only. It does not submit the app for App Store
review.

## Codemagic

Workflow:

```text
ios-testflight
```

Codemagic setup:

1. Add App Store Connect API key integration named
   `timebox_mark_app_store_connect`.
2. Configure iOS code signing for `com.seongwoo.focusmark` and
   `com.seongwoo.focusmark.PomodoroWidgetExtension`.
3. Create environment group `timebox_mark_ios_release`.
4. Add the Firebase and App Store Connect environment variables listed above.
5. Push an annotated tag matching `vMAJOR.MINOR.PATCH+BUILD`, or run the
   workflow manually. See `docs/release/BRANCHING_AND_TAGGING.md`.

## CircleCI

CircleCI is intentionally not used for iOS signing or upload. It runs fast
quality checks on Linux:

```bash
flutter pub get
dart run melos run codegen
dart run melos run guard
```

Connect the repository in CircleCI and let pull requests run the `quality`
workflow.

## Review Guardrails

The release guard checks:

- No ignored Firebase config or signing files are tracked.
- No obvious private key or CI secret values are in tracked files.
- iOS plist files are valid.
- Firebase JSON files are valid.
- Privacy, Terms, and Support URLs exist in tracked app/docs/site files.
- `flutter analyze` passes.
- `flutter test` passes.

## Shorebird

See `docs/release/SHOREBIRD_POLICY.md`.

GitHub Actions provides the pull-request quality gate. Codemagic provides the
manual `iOS TestFlight` Shorebird release and `iOS Shorebird Patch` workflows;
there is no branch-triggered automatic OTA publication.

The first patchable binary is built with `shorebird release ios` and still goes
through the normal TestFlight/App Store review flow. After it is installed, use
Shorebird only for small Dart-only hotfixes that do not alter native code or the
app's reviewed purpose, monetization, permissions, or privacy behavior.

The first end-to-end patch was published for `1.0.0+9`. It included only Dart
UI/state changes: full-card dragging while resize mode is active, visible trash
feedback, compact 15-minute card layout, and automatic schedule tracking for a
new card. Native timer, ActivityKit, entitlements, and permissions were not
changed.

## Android Release Signing

Debug builds use the generated Android debug key. Release builds deliberately
fail until a private upload key is configured. Copy
`android/key.properties.example` to ignored `android/key.properties`, replace
the placeholder values, and keep the referenced `.jks` outside version control.

## References

- Apple App Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
- Apple App Privacy Details: https://developer.apple.com/app-store/app-privacy-details/
- Apple TestFlight: https://developer.apple.com/testflight/
- Fastlane upload_to_testflight: https://docs.fastlane.tools/actions/upload_to_testflight/
- Fastlane deliver: https://docs.fastlane.tools/actions/deliver/
- Codemagic Flutter iOS publishing: https://docs.codemagic.io/flutter-publishing/publishing-to-app-store/
- CircleCI configuration reference: https://circleci.com/docs/configuration-reference/
- Shorebird App Store guide: https://docs.shorebird.dev/code-push/guides/stores/app-store/
