# Shorebird Policy

Status: not initialized in the submitted binary yet.

Use Shorebird only after a normal App Store Connect build has been accepted into
TestFlight or App Review. Do not use Shorebird for the first binary submission.

## Review-Safe Use

Allowed patch scope:

- Dart-only crash fixes
- Dart-only UI layout fixes
- Copy or localization corrections
- Defensive fixes for already-reviewed flows

Not allowed through Shorebird patches:

- New primary app features
- New login, billing, subscription, invite, or entitlement behavior
- New calendar scopes or background capabilities
- Native iOS, widget, Live Activity, notification, or entitlement changes
- Privacy policy, tracking, data collection, or account deletion behavior changes
- Anything that changes the app's purpose from what Apple reviewed

Those changes must go through a normal App Store Connect upload and review.

## Setup

Install and authenticate locally:

```bash
curl --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/shorebirdtech/install/main/install.sh | bash
shorebird login
shorebird init
```

`shorebird init` creates `shorebird.yaml` with the real Shorebird app id. Commit
that file only after confirming the app id belongs to Timebox Mark.

## Release Flow

Use a normal signed release for the first TestFlight/App Store binary:

```bash
cd ios
bundle exec fastlane ios internal_beta
```

After that release exists in Shorebird, small Dart-only hotfixes can use:

```bash
shorebird patch ios --release-version 1.0.0+1
```

Codemagic has an `ios-shorebird-patch` workflow, but it intentionally fails
until `shorebird.yaml`, `SHOREBIRD_TOKEN`, and `SHOREBIRD_RELEASE_VERSION` are
configured.

## Patch Checklist

- Write a one-line reason for the patch.
- Run `flutter analyze` and `flutter test`.
- Confirm no App Store metadata, privacy, paid feature, or permission behavior
  changed.
- Smoke test sign-in, Today, Focus, Live Activity, Settings, and Calendar.
- Keep the patch rollout small at first, then expand after verifying crash-free
  behavior.

## References

- Apple App Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
- Shorebird App Store guide: https://docs.shorebird.dev/code-push/guides/stores/app-store/
