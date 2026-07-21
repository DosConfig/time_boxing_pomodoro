# App Store Connect, Shorebird, And Codemagic Setup

This guide uses the current Timebox Mark production values:

- App Store Connect login: `seongwoo@10xkeleton.com`
- App Store Connect team/provider: `SEONGWOO DO|22759746113|1`
- Apple Developer Team ID: `HC9DTZBGLT`
- App bundle id: `com.seongwoo.focusmark`
- Widget extension bundle id: `com.seongwoo.focusmark.PomodoroWidgetExtension`
- Firebase project: `timebox-mark-prod`
- Public legal/support site: `https://timebox-mark-prod.web.app`

## 1. App Store Connect

### Create The App Record

1. Open App Store Connect > Apps.
2. Click `+` > New App.
3. Enter:
   - Platform: iOS
   - Name: Timebox Mark
   - Primary language: English or Korean
   - Bundle ID: `com.seongwoo.focusmark`
   - SKU: `timebox-mark-ios`
   - User Access: Full Access
4. Save.

### App Information

- Category: Productivity
- Privacy Policy URL: `https://timebox-mark-prod.web.app/privacy/`
- Support URL: `https://timebox-mark-prod.web.app/support/`
- Marketing URL: `https://timebox-mark-prod.web.app/`
- Age rating: 4+

Use:

- Store copy: `docs/store/APP_STORE_ASSETS.md`
- Privacy answers: `docs/release/APP_STORE_REVIEW_PREP.md`

### TestFlight Upload From Xcode

1. Open `ios/Runner.xcworkspace`.
2. Confirm `Runner` and `PomodoroWidgetExtensionExtension` use Team
   `HC9DTZBGLT`.
3. Product > Archive.
4. Organizer > Distribute App > App Store Connect > Upload.
5. Wait for processing in App Store Connect > TestFlight.
6. Add internal testers first.
7. Use external beta review only after internal smoke testing passes.

### TestFlight Registration

After the first build is uploaded and processed:

1. App Store Connect > Apps > Timebox Mark > TestFlight.
2. Open Test Information and fill in:
   - Beta App Description:
     `Timebox Mark helps testers plan a day with timeboxes, focus on the current block, receive local alerts, and export selected blocks to calendar.`
   - Feedback Email:
     `seongwoo@10xkeleton.com`
   - Marketing URL:
     `https://timebox-mark-prod.web.app/`
   - Privacy Policy URL:
     `https://timebox-mark-prod.web.app/privacy/`
3. Under Internal Testing, create a group:
   - Group name: `Internal Beta`
   - Enable automatic distribution if available.
4. Add internal testers from App Store Connect users.
5. Add the processed build to the group.
6. Enter What to Test:
   `Please test onboarding, Apple and Google sign-in, Today planning, dragging and resizing timeboxes, Focus timer sync, Live Activity, local notifications, settings, and Apple Calendar export.`
7. Install through the TestFlight app on a real device.

Internal testing is enough for the first smoke test. External testing is for
people outside App Store Connect users and may require Beta App Review before
external testers can install the build.

Recommended first internal tester list:

- Account holder: `seongwoo@10xkeleton.com`
- Any reviewer/test email that is already added under App Store Connect users

Do not create a public link until the first internal build has passed the smoke
test checklist.

### TestFlight Upload From Fastlane

Create an App Store Connect API key:

1. App Store Connect > Users and Access > Integrations > App Store Connect API.
2. Create a key with Developer or App Manager access.
3. Save:
   - `APP_STORE_CONNECT_KEY_ID`
   - `APP_STORE_CONNECT_ISSUER_ID`
   - `.p8` key content or filepath

Then run:

```bash
bundle install
cd ios
APPLE_ID=seongwoo@10xkeleton.com \
APPLE_TEAM_ID=HC9DTZBGLT \
APP_STORE_CONNECT_TEAM_ID=22759746113 \
APP_STORE_CONNECT_KEY_ID=... \
APP_STORE_CONNECT_ISSUER_ID=... \
APP_STORE_CONNECT_KEY_FILEPATH=/absolute/path/AuthKey_XXXX.p8 \
bundle exec fastlane ios internal_beta
```

## 2. Shorebird

Shorebird registration requires a Shorebird account login and creates a
project-specific `shorebird.yaml`.

Install and log in:

```bash
curl --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/shorebirdtech/install/main/install.sh | bash
shorebird login
shorebird init
```

After `shorebird init`, confirm `shorebird.yaml` belongs to Timebox Mark before
committing it.

### Recommended Review-Safe Policy

For the first App Store submission, use the normal Flutter/Fastlane/TestFlight
binary. Initialize Shorebird now if desired, but do not use it to ship patches
until a reviewed binary exists.

Use Shorebird only for Dart-only fixes that do not change:

- Login, billing, invite, or entitlement behavior
- Permissions or privacy behavior
- Calendar scopes
- Native iOS, widget, Live Activity, notification, or entitlement code
- The app's reviewed purpose

### Patch Flow After A Shorebird Release Exists

```bash
shorebird patch ios --release-version 1.0.0+1
```

Codemagic already has an `ios-shorebird-patch` workflow. It needs:

- `shorebird.yaml`
- `SHOREBIRD_TOKEN`
- `SHOREBIRD_RELEASE_VERSION`

## 3. Codemagic

The repo already contains `codemagic.yaml` with:

- `ios-testflight`
- `ios-shorebird-patch`

### Connect The Repository

1. Open Codemagic.
2. Add the Git repository.
3. Select YAML configuration from `codemagic.yaml`.

### App Store Connect Integration

Create an App Store Connect API key in App Store Connect and add it to
Codemagic as an integration named exactly:

```text
timebox_mark_app_store_connect
```

### Code Signing

Configure iOS signing in Codemagic for both bundle ids:

```text
com.seongwoo.focusmark
com.seongwoo.focusmark.PomodoroWidgetExtension
```

Use Apple Developer Team ID:

```text
HC9DTZBGLT
```

The workflow runs:

```bash
xcode-project use-profiles
flutter build ipa --release \
  --build-number=$BUILD_NUMBER \
  --export-options-plist=ios/ExportOptions.app-store.plist
```

### Environment Group

Create an environment group named:

```text
timebox_mark_ios_release
```

Add:

```text
APP_IDENTIFIER=com.seongwoo.focusmark
APPLE_ID=seongwoo@10xkeleton.com
APPLE_TEAM_ID=HC9DTZBGLT
APP_STORE_CONNECT_TEAM_ID=22759746113
APP_STORE_CONNECT_KEY_ID=
APP_STORE_CONNECT_ISSUER_ID=
APP_STORE_CONNECT_KEY_CONTENT=
APP_STORE_CONNECT_KEY_CONTENT_BASE64=false
FIREBASE_OPTIONS_DART_BASE64=
GOOGLE_SERVICE_INFO_PLIST_BASE64=
GOOGLE_SERVICES_JSON_BASE64=
GOOGLE_REVERSED_CLIENT_ID=
```

For Shorebird patch workflow, also add:

```text
SHOREBIRD_TOKEN=
SHOREBIRD_RELEASE_VERSION=
```

### Firebase Config Variables

Because Firebase client files are ignored in this public repo, encode them for
CI:

```bash
base64 -i lib/firebase_options.dart | pbcopy
base64 -i ios/Runner/GoogleService-Info.plist | pbcopy
base64 -i android/app/google-services.json | pbcopy
```

Store the copied values as:

- `FIREBASE_OPTIONS_DART_BASE64`
- `GOOGLE_SERVICE_INFO_PLIST_BASE64`
- `GOOGLE_SERVICES_JSON_BASE64`

Set `GOOGLE_REVERSED_CLIENT_ID` from `ios/Runner/GoogleService-Info.plist`.

### Run The Workflow

Either run `ios-testflight` manually in Codemagic, or push a tag:

```bash
git tag ios-1.0.0-1
git push origin ios-1.0.0-1
```

The current YAML uploads to TestFlight only. It does not submit to App Store
review.

## Verification Checklist

Before uploading:

```bash
dart run melos run codegen
dart run melos run guard
flutter build ios --release --no-codesign
```

After uploading:

1. Confirm the build appears in App Store Connect > TestFlight.
2. Install through TestFlight on a real device.
3. Smoke test:
   - First launch onboarding
   - Apple/Google sign-in
   - Firestore sync
   - Today timebox board
   - Focus timer
   - Live Activity
   - Local notification permission and completion alert
   - Apple Calendar export
   - Account deletion entry point

## References

- Apple TestFlight: https://developer.apple.com/testflight/
- App Store Connect API keys: https://developer.apple.com/help/app-store-connect/get-started/app-store-connect-api/
- Codemagic iOS publishing: https://docs.codemagic.io/flutter-publishing/publishing-to-app-store/
- Codemagic iOS code signing: https://docs.codemagic.io/yaml-code-signing/signing-ios/
- Fastlane upload_to_testflight: https://docs.fastlane.tools/actions/upload_to_testflight/
- Shorebird App Store guide: https://docs.shorebird.dev/code-push/guides/stores/app-store/
