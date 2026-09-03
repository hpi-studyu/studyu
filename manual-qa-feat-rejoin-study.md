# Manual QA: Rejoin study (`feat/rejoin-study`)

## Summary

The participant app adds a 13-word recovery phrase. A returning participant can restore an account and reopen the latest active study. A new participant can save the phrase after starting a study. An existing participant can view or replace the phrase in Settings. The app now asks an already signed-in participant to confirm before it replaces the current account. The main remaining risk is the real Supabase recovery boundary, where the app changes identity, signs in, and loads persisted study data. Scope uses the branch diff and user input. No Jira ticket was found. 5 test items: live-backend E2E automation passed against local Supabase (four independent `flutter drive` targets); browser/device checks remain manual QA.

## Setup (not test items)

- Start local Supabase. Use only local data.
- Use `.env.local` and start the participant app with `fvm exec melos local:app`.
- Use two local participant accounts.
- Give the first account an active study with saved progress. Save its recovery phrase.
- Give the second account a different active study or no active study.
- Prepare an account with no active study.
- Do not use a production account, recovery phrase, or study data.

## P1 — Must test

### Functional

- [ ] **Restore an account with saved study progress**
  - Steps:
    1. Sign out of the participant app.
    2. Open the welcome screen.
    3. Select **Restore StudyU account**.
    4. Enter the saved 13-word phrase for the account with an active study.
    5. Select **Restore account**.
  - Expected: The app signs in to the recovered account. It opens the latest active study. Saved study progress is present. The used phrase cannot restore the account again.
  - Coverage: Automated against local Supabase by `app/integration_test/recovery_e2e_active_test.dart` plus `app/integration_test/recovery_e2e_reused_phrase_test.dart` in a separate browser process. Passed on this branch: live RPC recovery, normal auth sign-in, dashboard routing, persisted-progress rendering, and one-time phrase invalidation.

- [ ] **Restore an account without an active study**
  - Steps:
    1. Sign out of the participant app.
    2. Restore the account with no active study.
  - Expected: The app signs in and opens the public study list. It does not show a stale dashboard or an error.
  - Coverage: Automated against local Supabase by `app/integration_test/recovery_e2e_no_study_test.dart`. Passed on this branch: public study selection without a stale dashboard or app error screen.

### UX

- [ ] **Confirm before replacing a signed-in account**
  - Steps:
    1. Sign in to one local participant account.
    2. Open **Restore StudyU account** and enter a different valid phrase.
    3. Select **Cancel**, then repeat and select **Restore account**.
  - Expected: Cancel keeps the original session. Restore replaces it only after confirmation and opens the recovered account destination.
  - Coverage: Automated against local Supabase by `app/integration_test/recovery_e2e_confirmation_test.dart`. Passed on this branch: cancel keeps the original session, restore replaces it only after confirmation. Retain manual review of copy and device behavior.

- [ ] **Use recovery actions in a supported browser and device**
  - Steps:
    1. Open Settings for a participant with a recovery phrase.
    2. Expand **View recovery phrase**.
    3. Select **Copy**.
    4. Paste the phrase into a safe temporary text field.
    5. Select **Download**.
    6. Inspect the downloaded file.
  - Expected: Copy preserves all 13 words in order. Download creates a readable text file with the same phrase. Each action gives clear feedback.
  - Coverage: Partially covered by `app/test/widgets/recovery_phrase_content_test.dart`. The test checks exact clipboard text and feedback. It does not test browser permission or the downloaded file.

## P2 — Should test

### Functional

- [ ] **Replace a recovery phrase in Settings**
  - Steps:
    1. Open Settings for a participant with an existing phrase.
    2. Expand **View recovery phrase**.
    3. Select **Reissue recovery phrase**.
    4. Select the acknowledgement checkbox.
    5. Save the replacement phrase.
    6. Sign out.
    7. Try the old phrase.
    8. Try the replacement phrase.
  - Expected: The reissue action stays disabled until acknowledged. The old phrase fails. The replacement phrase restores the account.
  - Coverage: Partially covered by `app/test/widgets/recovery_phrase_content_test.dart`, `app/test/services/restore_account_service_test.dart`, and `supabase/tests/rls/user_recovery_test.sql`. The tests cover acknowledgement, phrase update, and server-side rotation. They do not execute the full live restore sequence.

## P3 — Test if time allows

- [ ] **Inspect recovery screens on a narrow layout**
  - Steps:
    1. Open **Restore StudyU account** at a phone-width layout.
    2. Enter 12 words.
    3. Enter 13 valid words.
    4. Enter 14 words.
    5. Open the post-study recovery phrase prompt.
  - Expected: Text, word count, errors, and buttons remain visible. Controls do not overlap or clip. The restore button enables only for a valid 13-word phrase. The recovery phrase prompt requires confirmation before it closes.
  - Coverage: Partially covered by `app/test/screens/app_onboarding/restore_account_screen_test.dart`, `app/test/screens/app_onboarding/recovery_phrase_screen_test.dart`, and `app/test/screens/study/dashboard/dashboard_test.dart`. The tests verify behavior. They do not verify responsive rendering.

## Automated coverage

| Changed behavior | Test file | Command |
| --- | --- | --- |
| Phrase encoding, checksum, word count, and 128-bit limits | `core/test/util/recovery_test.dart` | `fvm exec melos exec --scope studyu_core -- "flutter test test/util/recovery_test.dart"` |
| Restore validation, signed-in confirmation, cancellation, safe errors, and routes with or without an active study | `app/test/screens/app_onboarding/restore_account_screen_test.dart` | `fvm exec melos exec --scope studyu_app -- "fvm flutter test test/screens/app_onboarding/restore_account_screen_test.dart"` |
| First-use phrase reveal and confirmation gate | `app/test/screens/app_onboarding/recovery_phrase_screen_test.dart` | `fvm exec melos exec --scope studyu_app -- "flutter test test/screens/app_onboarding/recovery_phrase_screen_test.dart"` |
| Lazy phrase loading, exact clipboard text, and phrase reissue | `app/test/widgets/recovery_phrase_content_test.dart` | `fvm exec melos exec --scope studyu_app -- "flutter test test/widgets/recovery_phrase_content_test.dart"` |
| Dashboard recovery prompt and acknowledgement gate | `app/test/screens/study/dashboard/dashboard_test.dart` | `fvm exec melos exec --scope studyu_app -- "flutter test test/screens/study/dashboard/dashboard_test.dart"` |
| Recovery cleanup order, active-subject handoff, and German phrase decoding | `app/test/services/restore_account_service_test.dart` | `fvm exec melos exec --scope studyu_app -- "fvm flutter test test/services/restore_account_service_test.dart"` |
| Live active-study, no-study, signed-in confirmation, and used-ID invalidation recovery (passed on this branch) | `app/integration_test/recovery_e2e_active_test.dart`, `app/integration_test/recovery_e2e_reused_phrase_test.dart`, `app/integration_test/recovery_e2e_no_study_test.dart`, `app/integration_test/recovery_e2e_confirmation_test.dart` | The workflow runs every `app/integration_test/*_test.dart` target sequentially, one new browser process each; alphabetical order keeps the used-ID target after active recovery. |
| Used recovery ID invalidation and rotation permissions | `supabase/tests/rls/user_recovery_test.sql` | `./scripts/reset-test-db.sh && supabase test db supabase/tests` |

The focused app suite passed on this branch:

```text
9 focused restore-account screen tests passed
```

Changed code with no tests:

- `app/lib/util/recovery_file_utils.dart` — no browser-level test for download permission or file-system behavior.
- `supabase/migrations/20260709120000_user_recovery.sql` — database tests cover RPC behavior, but not the full app-to-Supabase recovery flow.

## Regression watch

- The recovery phrase is a credential. Confirm that screenshots, browser history, logs, and error messages do not expose it.
- Recovery rotates the recovery ID. Confirm that a used or replaced phrase cannot restore the account again.
- The app tests confirm account replacement, cancellation, and recovery routing. Manually confirm that the message is clear on supported devices.
- Confirm that the app shows no raw database error, credential, or stack trace when recovery fails.

## Out of scope (safe to skip)

- Designer study preview and language synchronization — not required for participant account recovery.
- Required multi-choice questionnaire answers — separate questionnaire behavior.
- Public-study browsing and invite deep links — separate onboarding behavior unless the release includes those changes.

> This scope is a floor, not a ceiling. It reflects what the diff demonstrably changes. Use exploratory testing and tester judgment as needed.
