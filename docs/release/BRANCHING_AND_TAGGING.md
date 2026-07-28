# Branching And Release Tagging

Status: active

Timebox Mark uses a lightweight trunk-based workflow. `main` is the only
long-lived branch and must remain releasable.

## Branches

Create short-lived branches from the latest `main`:

```text
feature/<short-description>   product work
fix/<short-description>       defect fixes before release
hotfix/<short-description>    urgent fixes for an existing store release
chore/<short-description>     tooling, documentation, and maintenance
```

Examples:

```text
fix/pomodoro-lifecycle-reconciliation
feature/daily-review
hotfix/timer-restore-crash
chore/branching-release-policy
```

Do not create long-lived `develop`, `staging`, or `release` branches. Release
state is represented by an immutable tag, not by a permanent branch.

## Pull Requests

All changes reach `main` through a pull request, including solo work.

Before merge:

1. Rebase or update the branch with the latest `main`.
2. Complete the pull request risk checklist.
3. Pass the `flutter-gate` GitHub Actions check.
4. Run relevant real-device checks for timer, notification, Live Activity, or
   platform-channel changes.
5. Squash merge unless preserving multiple commits materially helps a future
   revert or investigation.

Recommended GitHub branch protection for `main`:

- Require a pull request before merging.
- Require the `flutter-gate` status check.
- Require branches to be up to date before merging.
- Block force pushes and deletion.
- Allow the repository owner to merge without a second human approval; this is
  currently a solo-maintained project.

## Release Tags

The canonical tag format mirrors Flutter's version and build number:

```text
vMAJOR.MINOR.PATCH+BUILD
```

Examples:

```text
v1.0.0+3
v1.0.1+4
v1.1.0+5
```

Rules:

- `MAJOR.MINOR.PATCH` must equal the version in `pubspec.yaml`.
- `BUILD` must equal the build number after `+` in `pubspec.yaml`.
- Every store/TestFlight candidate receives one immutable annotated tag.
- Never move or recreate a published tag. Increment `BUILD` instead.
- Existing `ios-*` tags are legacy tags and remain untouched.
- A release tag points to a commit already merged into `main`.

Create and push a release tag:

```bash
git switch main
git pull --ff-only origin main
git tag -a 'v1.0.1+4' -m 'Timebox Mark 1.0.1 (4)'
git push origin 'v1.0.1+4'
```

## Normal Release

```text
short-lived branch
→ pull request
→ flutter-gate
→ merge to main
→ update pubspec version
→ annotated vX.Y.Z+BUILD tag
→ Codemagic/Fastlane TestFlight build
→ smoke test
→ App Store rollout
```

## Hotfix

Create a hotfix branch from the exact released tag when `main` already contains
unreleased work:

```bash
git switch -c hotfix/timer-restore-crash 'v1.0.1+4'
```

After verification, merge the fix back into `main`, increment the build number,
and create a new release tag. Native, ActivityKit, entitlement, permission, and
platform-channel changes always use this normal binary release path.

## Shorebird Boundary

Shorebird CI is not used. GitHub Actions remains the pull-request quality gate.

Shorebird Code Push is a separate, future release mechanism. It remains inactive
until a normal reviewed binary exists. If activated later, only eligible
Dart-only fixes may use it, following `docs/release/SHOREBIRD_POLICY.md`.
