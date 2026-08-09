# PR 906 Follow-up Checklist

Last updated: 2026-08-09

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

Status: in progress

Goal:
- Make cache-missing / cache-corrupt startup failures route through an explicit recoverable path instead of generic fall-through behavior.

Acceptance:
- [ ] Missing cached subject during degraded startup shows recoverable app error flow.
- [ ] Corrupt cached subject during degraded startup shows recoverable app error flow.
- [ ] Flow does not crash or spin forever.

### 2. Validate cached participant restart while backend is unavailable

Status: pending

Goal:
- Verify already-enrolled participant with cached subject can restart app while backend is down and still reach usable cached state.

Acceptance:
- [ ] Restart with backend unavailable reaches cached participant flow.
- [ ] No manual storage cleanup needed.
- [ ] No replacement participant account created during outage.

### 3. Validate cached participant restart while device is offline

Status: pending

Goal:
- Verify same flow as item 2 with device/network offline, not only backend down.

Acceptance:
- [ ] Offline restart reaches cached participant flow.
- [ ] Offline banner shown.

### 4. Validate cached study data completeness

Status: pending

Goal:
- Confirm cached study configuration, schedule, task state, and participant progress all remain available during outage.

Acceptance:
- [ ] Cached configuration available.
- [ ] Cached schedule available.
- [ ] Cached task state available.
- [ ] Cached participant progress available.

### 5. Offline task completion persistence

Status: pending

Goal:
- Confirm participant can complete eligible cached tasks offline and local work survives restarts.

Acceptance:
- [ ] Offline answers persist.
- [ ] Completion timestamps persist.
- [ ] Progress persists.
- [ ] Pending media uploads persist.

### 6. Safe reconnect synchronization

Status: pending

Goal:
- Confirm reconnect sync uploads locally completed work to same participant + study without duplication or loss.

Acceptance:
- [ ] Sync resumes automatically after reconnect.
- [ ] No duplicate task completions.
- [ ] No lost progress.
- [ ] No wrong-account / wrong-backend upload.

### 7. Partial sync retry behavior

Status: pending

Goal:
- Handle mixed-success sync safely.

Acceptance:
- [ ] Partial failures stay queued.
- [ ] Retry remains safe and idempotent enough for app behavior.

### 8. Removal / deleted-participant stale-data policy

Status: pending, product decision needed

Goal:
- Define what happens to local cached study data after participant removal or deleted remote subject.

Questions:
- [ ] Retain local cache?
- [ ] Delete local cache?
- [ ] Offer recovery/export/support path?

### 9. Deleted participant cannot regain deleted study data

Status: pending

Goal:
- After removal, stale local/remote state must not restore access to deleted subject.

Acceptance:
- [ ] Removed participant cannot re-enter deleted study through stale state.
- [ ] Behavior matches policy from item 8.

## Notes

- Console/debug stack noise during expected backend outages is intentionally left as-is for now.
- `supabase/snippets/` is unrelated local work and not part of this checklist.
