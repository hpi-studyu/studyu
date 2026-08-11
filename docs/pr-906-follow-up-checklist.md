# PR 906 Follow-up Checklist

Last updated: 2026-08-10

Purpose: keep remaining work for PR #906 in one place, ordered from smallest to largest.

## Done

- [x] Recover startup when all configured Supabase backends are unreachable.
- [x] Initialize Supabase with fallback URL so offline/cache paths can run.
- [x] Clear stale participant credentials only on explicit `invalid_credentials`.
- [x] Preserve credentials on network/backend outage.
- [x] Validate stale participant session against active backend before reuse.
- [x] Add shared degraded-connection banner across participant app.
- [x] Distinguish device offline vs backend unavailable in shared connection state.
- [x] Reduce degraded auth auto-refresh and auth recovery retry churn.
- [x] Reproduce and fix main Terms -> Next stale-credentials backend-switch path.

## Remaining (smallest -> largest)

### 1. Explicit cache-failure recovery path

Status: done

Goal:
- Make cache-missing / cache-corrupt startup failures route through an explicit recoverable path instead of generic fall-through behavior.

Acceptance:
- [x] Missing cached subject during degraded startup shows recoverable app error flow.
- [x] Corrupt cached subject during degraded startup shows recoverable app error flow.
- [x] Flow does not crash or spin forever.

Progress:
- Startup recovery maps missing-cache and corrupt-cache restore failures to explicit recoverable app-error reasons.
- Focused widget coverage now verifies both cache-recovery screens render user-facing recovery actions instead of hanging on loading flow.

### 2. Validate cached participant restart while backend is unavailable

Status: done

Goal:
- Verify already-enrolled participant with cached subject can restart app while backend is down and still reach usable cached state.

Acceptance:
- [x] Restart with backend unavailable reaches cached participant flow.
- [x] No manual storage cleanup needed.
- [x] No replacement participant account created during outage.

Progress:
- Focused startup recovery tests now verify degraded backend path uses cached subject without re-auth retry.
- Participant auth recovery tests verify degraded connectivity blocks signup fallback, so outage restart does not create replacement participant accounts.

### 3. Validate cached participant restart while device is offline

Status: done

Goal:
- Verify same flow as item 2 with device/network offline, not only backend down.

Acceptance:
- [x] Offline restart reaches cached participant flow.
- [x] Offline banner shown.

Progress:
- Focused startup recovery tests now verify explicit offline transport failures restore cached subject state, skip re-auth retry, and set shared connection state to `deviceOffline`.
- Shared banner widget coverage already verifies offline status renders offline copy across participant surfaces.

### 4. Validate cached study data completeness

Status: done

Goal:
- Confirm cached study configuration, schedule, task state, and participant progress all remain available during outage.

Acceptance:
- [x] Cached configuration available.
- [x] Cached schedule available.
- [x] Cached task state available.
- [x] Cached participant progress available.

Progress:
- Focused `StudySubject` cache roundtrip test now verifies serialized cached subject keeps study config, schedule, task state, and participant progress intact.

### 5. Offline task completion persistence

Status: done

Goal:
- Confirm participant can complete eligible cached tasks offline and local work survives restarts.

Acceptance:
- [x] Offline answers persist.
- [x] Completion timestamps persist.
- [x] Progress persists.
- [x] Pending media uploads persist.

Progress:
- Focused app tests now verify offline checkmark progress survives cache reload and offline questionnaire media answers keep pending upload files across restart-like cache reload.

### 6. Safe reconnect synchronization

Status: in progress

Goal:
- Confirm reconnect sync uploads locally completed work to same participant + study without duplication or loss.

Acceptance:
- [ ] Sync resumes automatically after reconnect.
- [ ] No duplicate task completions.
- [ ] No lost progress.
- [ ] No wrong-account / wrong-backend upload.

Progress:
- Sync planning now merges by full serialized progress entry instead of list length or timestamp alone, preventing same-length local/remote divergence from dropping data and preventing distinct tasks at the same timestamp from being collapsed.
- Focused sync tests now cover no-loss merge, no duplicate resubmission, and same-timestamp multi-task preservation.
- Cache sync now refuses to merge when cached subject identity does not match remote `id` / `studyId` / `userId`, preventing stale cache from syncing into wrong participant or study after backend/account changes.
- `AppState` now retries subject synchronization automatically while connectivity is degraded and an active subject exists, then clears degraded state once remote fetch + sync succeeds.

### 7. Partial sync retry behavior

Status: done

Goal:
- Handle mixed-success sync safely.

Acceptance:
- [x] Partial failures stay queued.
- [x] Retry remains safe and idempotent enough for app behavior.

Progress:
- Blob upload sync now uses a sequential helper that only removes files after successful upload, so failed later uploads remain queued.
- Progress sync now uses an injectable sequential helper, and focused tests cover partial progress-save failure followed by a retry plan that contains only the unsynced remainder.

### 8. Removal / deleted-participant stale-data policy

Status: pending, product decision needed

Goal:
- Define what happens to local cached study data after participant removal or deleted remote subject.

Questions:
- [ ] Retain local cache?
- [ ] Delete local cache?
- [ ] Offer recovery/export/support path?

Progress:
- Deleted-subject recovery path now clears cached subject payload and active subject reference before routing to recovery UI, so stale local state is not reused automatically after backend-side removal.

### 9. Deleted participant cannot regain deleted study data

Status: in progress

Goal:
- After removal, stale local/remote state must not restore access to deleted subject.

Acceptance:
- [ ] Removed participant cannot re-enter deleted study through stale state.
- [ ] Behavior matches policy from item 8.

Progress:
- Deleted-subject startup detection now clears local cached subject state and active subject reference before recovery routing.
- Deleted-study recovery reset path now clears only deleted-subject local state instead of doing a broad storage wipe.
- Cache synchronization now refuses mismatched cached subject identity, so stale cached progress cannot be merged into a different remote participant/study during later reconnect.

## Notes

- Console/debug stack noise during expected backend outages is intentionally left as-is for now.
- `supabase/snippets/` is unrelated local work and not part of this checklist.
