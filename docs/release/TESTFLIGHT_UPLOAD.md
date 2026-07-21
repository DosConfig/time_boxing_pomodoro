# TestFlight Upload Runbook

Status: not uploaded yet. This repo is prepared for a signed archive, but
TestFlight upload requires Apple Developer signing credentials and App Store
Connect access.

## Required From The Apple Account Owner

- App Store Connect account: `seongwoo@10xkeleton.com`
- App Store Connect team/provider: `SEONGWOO DO|22759746113|1`
- Active Apple Developer Program membership
- App Store Connect app record for bundle ID `com.seongwoo.focusmark`
- Apple Developer Team selected for:
  - `Runner`
  - `PomodoroWidgetExtensionExtension`
- Bundle IDs and capabilities enabled:
  - `com.seongwoo.focusmark`
  - `com.seongwoo.focusmark.PomodoroWidgetExtension`
  - Sign in with Apple
  - Live Activities
- App Store Connect API key or Apple ID plus app-specific password

Keep `APPLE_TEAM_ID=HC9DTZBGLT` unless Apple Developer > Membership shows a
different 10-character Developer Team ID. The `22759746113` value from App Store
Connect is the App Store Connect provider/team id used by Fastlane as
`APP_STORE_CONNECT_TEAM_ID`.

## Metadata To Enter In App Store Connect

- Privacy Policy URL: https://timebox-mark-prod.web.app/privacy/
- Support URL: https://timebox-mark-prod.web.app/support/
- Terms URL: https://timebox-mark-prod.web.app/terms/
- Category: Productivity
- Age rating: 4+
- Review notes: use `docs/store/APP_STORE_ASSETS.md`
- Privacy answers: use `docs/release/APP_STORE_REVIEW_PREP.md`

## Local Verification Before Upload

```bash
flutter gen-l10n
dart run build_runner build
flutter analyze
flutter test
flutter build ios --release --no-codesign
```

The same checks are wrapped by:

```bash
bash scripts/ci/verify_release_guardrails.sh
```

## Build And Upload With Xcode

1. Open `ios/Runner.xcworkspace`.
2. Select `Runner` target and choose the Apple Developer Team.
3. Select `PomodoroWidgetExtensionExtension` target and choose the same team.
4. Confirm `Runner/Runner.entitlements` is attached to Runner.
5. Product > Archive.
6. In Organizer, choose Distribute App > App Store Connect > Upload.
7. Wait for processing in App Store Connect > TestFlight.
8. Add internal testers, then submit external beta review if needed.

## Build And Upload With CLI

After signing is configured locally:

```bash
flutter build ipa --release \
  --export-options-plist=ios/ExportOptions.app-store.plist
xcrun altool --upload-app \
  --type ios \
  --file build/ios/ipa/*.ipa \
  --username "$APP_STORE_CONNECT_USERNAME" \
  --password "$APP_STORE_CONNECT_APP_PASSWORD"
```

For CI, prefer App Store Connect API keys instead of a personal password.

## Build And Upload With Fastlane

Fastlane configuration now lives in `ios/fastlane`.

```bash
bundle install
cd ios
bundle exec fastlane ios verify
bundle exec fastlane ios internal_beta
```

Required environment variables are documented in `.env.example` and
`docs/release/RELEASE_AUTOMATION.md`.

## Build And Upload With Codemagic

Codemagic configuration now lives in `codemagic.yaml`.

Use the `ios-testflight` workflow after configuring:

- App Store Connect integration `timebox_mark_app_store_connect`
- Environment group `timebox_mark_ios_release`
- Code signing profiles for the Runner and widget extension bundle IDs
- Base64-encoded Firebase client files and Google reversed client ID
  - `APPLE_ID=seongwoo@10xkeleton.com`
  - `APPLE_TEAM_ID=HC9DTZBGLT`
  - `APP_STORE_CONNECT_TEAM_ID=22759746113`

The workflow uploads to TestFlight only. It does not submit the app for App
Store review.

## Current Local Status

- `flutter build ios --release --no-codesign` succeeds.
- Firebase Hosting legal/support pages are deployed.
- Firestore rules are deployed.
- Firestore code writes `users/{uid}` and `users/{uid}/days/{yyyy-MM-dd}` after
  a signed-in user edits the plan; production document creation must still be
  confirmed with a real-device smoke test.
- Fastlane and Codemagic release automation files are prepared.
- Shorebird is documented and guarded, but not initialized in the submitted
  binary.
- TestFlight upload is blocked only by Apple signing/App Store Connect
  credentials, Codemagic signing setup, and the app record setup.
