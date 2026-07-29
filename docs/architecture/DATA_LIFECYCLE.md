# Today Plan Data Lifecycle

## Source Of Truth

Today Plan data is stored per Firebase user and calendar date.

- Local cache key: `Firebase UID + local date`
- Cloud document: `users/{uid}/days/{yyyy-MM-dd}`
- Daily content: top priorities, brain dump, reminders, time boxes, active box,
  and completed-session count
- Native timer state: timer status, remaining time, alert preferences, and the
  active time-box display copy only

Native timer restoration must never replace daily content. Calendar export is
read-only with respect to Today Plan and stores only provider event mappings.

## Startup

1. Resolve the authenticated Firebase user.
2. Open that user's local date cache.
3. Load the matching Firestore day document.
4. Resolve local and cloud revisions.
5. Persist the resolved revision locally and, when local wins, to Firestore.
6. Restore native timer runtime fields.
7. Enable clock synchronization and user mutations.

Writes before step 5 are rejected. This prevents the default empty entity from
overwriting a saved plan while asynchronous restoration is pending.

## Calendar Export

1. Build an immutable export request from scheduled time boxes.
2. Export only items without an existing provider mapping.
3. Store successful `timeBoxId -> eventId` mappings.
4. Leave priorities, brain dump, reminders, and time boxes unchanged.
5. When the app resumes, restore only native timer runtime fields.

## Authentication Transitions

- Every local key is scoped by Firebase UID, preventing account cache mixing.
- A queued local write captures the UID at edit time.
- A queued cloud write captures the UID at edit time and is discarded if the
  authenticated user changes before execution.
- Pending writes are flushed before sign-out or account deletion.
- Focus controller and repository providers are recreated after auth changes.
- Legacy unscoped local records migrate once to the first signed-in user.

## Day Rollover

At local midnight, the previous day remains stored under its original date.
The new day starts with empty priorities, brain dump, and reminders. Only time
boxes whose recurrence includes the new weekday are carried forward. Manual
carry-over remains available for the other daily lists.

An empty Today screen therefore does not imply that the app container was
cleared. Diagnose it by checking the current Firebase UID and today's dated
record separately from previous-day history. A TestFlight update or Shorebird
patch must not delete `SharedPreferences` or Firestore day documents.

## Regression Coverage

- Delayed startup restoration cannot persist an empty plan.
- Native timer restoration preserves all daily-plan fields.
- App restart restores the same user's plan.
- Another user cannot read the first user's local plan.
- Queued writes retain their original user scope.
- Legacy local records migrate without becoming visible to another account.
- Calendar export deduplicates provider events without mutating Today Plan.
