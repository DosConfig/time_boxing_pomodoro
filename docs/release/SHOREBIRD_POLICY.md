# Shorebird Policy

Status: initialized. New store binaries are created with the Shorebird release
workflow; patches remain restricted by the policy below.

This policy is for Shorebird Code Push only. Shorebird CI is not used; pull
request checks run in GitHub Actions.

The first patchable binary must be created with `shorebird release ios` and
uploaded through the normal TestFlight/App Store review flow. A binary built
only with `flutter build ipa` cannot receive a Shorebird patch.

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

`shorebird.yaml` contains the Timebox Mark Shorebird app id. Codemagic stores
the API key as the encrypted `SHOREBIRD_TOKEN` variable in the
`timebox_mark_ios_release` group. Never commit that token.

## Release Flow

Run the Codemagic `iOS TestFlight` workflow from an annotated release tag. It
uses `shorebird release ios`, produces the signed IPA, registers the release
with Shorebird, and uploads the same IPA to TestFlight.

After that release exists in Shorebird, small Dart-only hotfixes can use:

```bash
shorebird patch ios --release-version 1.0.0+1
```

For a Dart-only hotfix, manually run the Codemagic `iOS Shorebird Patch`
workflow and enter the installed release version, such as `1.0.0+4`, in its
`release_version` input.

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
