# Account Ownership Migration

Target production identity:

- Public support/contact email: `seongwoo@10xkeleton.com`
- App Store Connect account: `seongwoo@10xkeleton.com`
- App Store Connect team/provider: `SEONGWOO DO|22759746113|1`
- Apple bundle id: `com.seongwoo.focusmark`
- Firebase/GCP project: `timebox-mark-prod`
- Public site: `https://timebox-mark-prod.web.app`

## Current Verification Status

Verified on July 20, 2026:

- `gcloud` local account: `seongwoo@10xkeleton.com`
- `gcloud` local project: `timebox-mark-prod`
- Firebase CLI local account: `seongwoo@10xkeleton.com`
- Firebase project visible to the new account: `timebox-mark-prod`
- Hosting deploy succeeds with the new account
- Firestore rules deploy succeeds with the new account
- FlutterFire iOS config regenerates for:
  - Project: `timebox-mark-prod`
  - Bundle id: `com.seongwoo.focusmark`
  - Firebase iOS app id: `1:135782331609:ios:2a2f70f4bec6f8ba4dbac8`

The previous Google account is still listed as an Owner. Keep it until the App
Store/TestFlight release and CI credentials are confirmed under the production
account, then remove it manually from Google Cloud IAM if desired.

## What This Repo Can Change

- Public website contact links in `public/`
- App Store metadata drafts in `docs/store/`
- Legal draft contact email in `docs/legal/`
- Fastlane/Codemagic environment examples in `.env.example`
- Release runbooks in `docs/release/`

## What Must Be Changed In Consoles

### Google Cloud And Firebase

`seongwoo@10xkeleton.com` must exist as a Google identity before it can be added
to Firebase/GCP IAM. An Apple ID or ordinary email address is not enough. If IAM
returns `User seongwoo@10xkeleton.com does not exist`, create either:

- a Google account using the existing `seongwoo@10xkeleton.com` email address, or
- a Google Workspace / Cloud Identity user for `10xkeleton.com`.

1. Add `seongwoo@10xkeleton.com` to Google Cloud IAM for project
   `timebox-mark-prod`.
2. Grant at least the roles needed for the current release workflow:
   - Firebase Admin
   - Cloud Datastore Owner or Firestore Admin
   - Service Usage Admin
   - Project IAM Admin only if this account will manage other members
3. In Firebase Console > Project settings > Users and permissions, confirm
   `seongwoo@10xkeleton.com` can manage Authentication, Firestore, and Hosting.
4. In Google Cloud APIs & Services > OAuth consent screen, set the developer
   contact email to `seongwoo@10xkeleton.com`.
5. In Google Cloud APIs & Services > Credentials, confirm OAuth client ids for
   iOS and Google sign-in belong to `timebox-mark-prod`.
6. Log in locally:

```bash
gcloud auth login seongwoo@10xkeleton.com
gcloud config set account seongwoo@10xkeleton.com
gcloud config set project timebox-mark-prod
firebase login:add seongwoo@10xkeleton.com
```

Do not remove the previous Google account from IAM until
`seongwoo@10xkeleton.com` can deploy Hosting, deploy Firestore rules, and run
FlutterFire configuration for the project.

### Apple

1. Confirm the app is created under the App Store Connect team
   `SEONGWOO DO|22759746113|1`.
2. Confirm bundle ids exist in Apple Developer:
   - `com.seongwoo.focusmark`
   - `com.seongwoo.focusmark.PomodoroWidgetExtension`
3. Confirm capabilities:
   - Sign in with Apple
   - Live Activities
   - App Groups if widget/Live Activity sharing uses it
4. Keep `APPLE_TEAM_ID=HC9DTZBGLT` unless Apple Developer > Membership shows a
   different 10-character Developer Team ID.
5. Create an App Store Connect API key for CI and store it only in Codemagic or
   a local untracked `.env`.

### CI And Release Services

1. Codemagic:
   - App Store Connect integration: `timebox_mark_app_store_connect`
   - Environment group: `timebox_mark_ios_release`
   - `APPLE_ID=seongwoo@10xkeleton.com`
   - `APPLE_TEAM_ID=HC9DTZBGLT`
   - `APP_STORE_CONNECT_TEAM_ID=22759746113`
2. CircleCI:
   - No App Store signing secrets are required.
   - Use it for analyze/test/guard only.
3. Shorebird:
   - Initialize only after the first App Store-reviewed binary exists.
   - Keep `SHOREBIRD_TOKEN` outside the repo.

## Verification

```bash
rg -n "qlqjsdmsz8@gmail\\.com" . \
  -g '!build/**' \
  -g '!ios/build/**' \
  -g '!ios/Pods/**'
gcloud config list core/account core/project
firebase projects:list
firebase deploy --only hosting
```
