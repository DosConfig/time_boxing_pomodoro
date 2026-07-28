## What changed

<!-- Describe the user or engineering problem and the chosen change. -->

## Why this approach

<!-- Alternatives considered and the main trade-off. -->

## Verification

- [ ] `flutter-gate` passes
- [ ] Relevant unit/widget/integration tests pass
- [ ] Manual smoke test completed where needed

## Mobile lifecycle and release risk

- [ ] No lifecycle, timer, background, notification, or resource ownership change
- [ ] No Method Channel contract or Native code change
- [ ] No Live Activity, entitlement, permission, or privacy behavior change
- [ ] If any item above changed, the real-device scenarios and Store binary release requirement are documented below

<!-- Describe affected states: foreground, background, resumed, terminated, offline. -->

## Rollback

<!-- State whether reverting this PR is sufficient and note any data migration. -->
