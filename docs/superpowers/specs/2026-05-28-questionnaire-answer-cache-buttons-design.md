# Questionnaire Answer Cache and Button Visibility Requirements

## Goal

Improve questionnaire editing behavior so users can safely revise earlier
answers without losing hidden path answers unnecessarily, while preventing stale
answers from being submitted.

## Scope

Applies to participant-facing questionnaire flow in the app.

Covers:

- Hidden answer caching for all question types.
- Restoring cached answers when questions reappear.
- Complete button visibility and validation behavior.
- Free-text Submit button visibility and submission rules.
- Conditional and non-conditional free-text edit behavior.

## Definitions

- **Visible answer:** Answer for a question currently shown in the
  questionnaire.
- **Hidden answer:** Answer for a question that was previously shown but is
  currently hidden because conditional visibility changed.
- **Current completion payload:** The `QuestionnaireState` passed to final
  completion/submission.
- **Current visible path:** The currently shown set of questions after
  evaluating conditionals.
- **Free-text Submit:** The per-question Submit button inside
  `FreeTextQuestionWidget`.
- **Complete button:** The global questionnaire/task completion button outside
  individual questions.

## Answer Cache Requirements

### Session-only cache

Hidden answers must be cached only for the current questionnaire session.

- Cache is not persisted across app restarts.
- Cache is not shared between task runs.
- Cache is discarded when the questionnaire widget/session is disposed.

### Cache key

Hidden answers are cached by question id.

- If a question becomes hidden, its current answer is moved from visible state
  to cache under that question id.
- If the same question id becomes visible again later, its cached answer is
  restored.

### All question types

Caching applies to all question types, including:

- Free text
- Choice
- Boolean
- Scale
- Image
- Audio
- Pain
- Fitbit
- Any other questionnaire question type supported by the app

### Restore into state and UI

When a hidden question becomes visible again:

- Restore cached answer into questionnaire state.
- Restore cached value into the visible UI control where possible.
- Restored answers count as current visible answers.
- If UI restoration is not yet supported for a question type, implementation
  must explicitly document the gap and avoid falsely marking the visible
  question as completed unless the UI reflects the restored value.

### Completion payload

Complete must submit only answers for currently visible questions.

- Hidden cached answers must not be included in final `QuestionnaireState`.
- Hidden cached answers remain available for restoration during the session.
- Default answers for skipped conditional questions may still be included only
  if current existing business logic requires them, but this should be reviewed
  carefully against the "visible answers only" rule.

## Conditional Visibility Requirements

### When a path changes

When an answer change causes later questions to become hidden:

- Remove hidden questions from the visible question list.
- Move their current answers into the hidden-answer cache.
- Remove hidden answers from current visible questionnaire state.
- Emit incomplete/null completion state if the visible questionnaire is no
  longer complete.

### When a path returns

When conditional logic makes previously hidden questions visible again:

- Restore cached answers by question id.
- Restore UI values.
- Recalculate completion state based only on visible questions.
- If all visible questions have valid restored/current answers, Complete may be
  available.

## Free-text Submit Button Requirements

### Visibility

Free-text Submit must only be visible when the free-text question is the
last/current active visible question and explicit submission is needed.

Submit must be hidden for earlier non-last free-text questions.

### Conditional free-text edits

If an earlier free-text question has conditional dependents:

- Editing it must not immediately change branches on every keystroke.
- Valid-to-valid edits must not silently update the stored answer while later
  dependent questions remain visible.
- The questionnaire should become incomplete/pending.
- Later dependent questions should be removed/cached when the edit invalidates
  the current branch.
- The edited free-text question becomes current/last.
- Submit becomes visible.
- The new branch applies only after pressing Submit.

### Non-conditional free-text edits

If an earlier free-text question has no conditional dependents:

- Editing it must not remove later visible questions.
- Later answers remain visible and current.
- Submit stays hidden because the free-text question is not last/current.
- Valid edits may sync by debounce.
- Complete click must also sync latest valid visible free-text values before
  submitting.
- Invalid edits must prevent successful completion.

### Keyboard Done behavior

Keyboard Done must follow the same rules as the visible Submit button.

- If Submit is hidden because the free-text question is not current/last,
  keyboard Done must not submit or apply conditional branch changes.
- If the free-text question is current/last and Submit would be visible,
  keyboard Done may behave like Submit.

## Complete Button Requirements

### Visibility/clickability

Complete should be visible/clickable once all currently visible questions have
some answer or entered value, even if validation might still fail.

Complete must not include hidden cached answers in the payload.

### On Complete click

When Complete is clicked:

1. Validate all currently visible questions.
2. Sync all visible free-text fields so latest typed values are used.
3. If validation succeeds:
   - Submit only currently visible answers.
4. If validation fails:
   - Do not complete.
   - Scroll to the first visible validation error in the question list.
   - Show validation error state for invalid fields.

### Invalid visible fields

If any visible free-text field contains invalid typed text:

- Complete click must not submit.
- App must scroll to the first validation error.
- Current completion payload must remain unchanged.
- Hidden cached answers remain hidden and unsent.

## State Consistency Requirements

### No stale answer submission

The app must never submit an old stored answer when the user has typed a newer
visible value.

Examples:

- Q1 previously submitted `2`.
- User edits Q1 to `23`.
- Complete must not submit `2` if `23` is visible in the field.
- Either `23` is validated and synced, or completion is blocked with validation
  feedback.

### No conditional path churn

Conditional paths must not switch repeatedly on every free-text keystroke.

- Branch changes from free-text conditionals apply only on explicit Submit when
  the free-text question is current/last.
- This prevents path A/path B questions from appearing/disappearing while the
  user is still typing.

### Hidden cache does not equal submitted state

Cached hidden answers are not part of the current submitted state.

- Cache is only for restoration.
- Current `QuestionnaireState` should represent visible answers only.

## Testing Requirements

### Unit/widget tests: answer cache

Test that:

- Answers for hidden questions are cached when questions disappear.
- Cached answers are removed from current completion payload.
- Cached answers restore when same question id becomes visible again.
- Restored answers appear in UI controls where supported.
- Cache is session-only.

### Widget tests: conditional path behavior

Test flow:

1. Q1 controls whether Q2 appears.
2. Answer Q1 so Q2 appears.
3. Answer Q2.
4. Change Q1 so Q2 disappears.
5. Complete payload excludes Q2.
6. Change Q1 back so Q2 appears.
7. Q2 answer is restored in state and UI.
8. Complete payload includes restored Q2 only while visible.

### Widget tests: non-conditional free-text edits

Test flow:

1. Q1, Q2, Q3 are all non-conditional visible questions.
2. Answer all.
3. Edit Q1 valid-to-valid.
4. Q2/Q3 remain visible and answered.
5. Submit button for Q1 remains hidden.
6. Complete syncs latest Q1 value and submits Q1/Q2/Q3.
7. No stale Q1 answer is submitted.

### Widget tests: conditional free-text edits

Test flow:

1. Q1 free-text controls later conditional questions.
2. Submit Q1 value that shows path A.
3. Answer path A questions.
4. Edit Q1 to another valid value.
5. Path does not change on debounce while typing.
6. Questionnaire becomes pending/incomplete.
7. Q1 becomes current/last and Submit visible.
8. Press Submit.
9. New path applies.
10. Old path answers are cached but excluded while hidden.

### Widget tests: Complete validation

Test that:

- Complete is clickable when visible questions have entered values.
- Clicking Complete validates all visible free-text fields.
- Invalid free-text blocks completion.
- UI scrolls to first validation error.
- Valid free-text values are synced before completion.
- Hidden cached answers are not sent.

### Widget tests: keyboard Done

Test that:

- Keyboard Done does not submit a non-last free-text question when Submit is
  hidden.
- Keyboard Done can submit the current/last free-text question when Submit would
  be visible.

## Non-goals

- Persist hidden-answer cache across app restarts.
- Change study data model or backend payload format.
- Submit hidden answers.
- Switch free-text conditional paths on every keystroke.
- Rework visual design beyond required button visibility and validation
  behavior.

## Acceptance Criteria

Implementation is accepted when:

- Hidden answers are cached for all question types during the questionnaire
  session.
- Hidden answers restore by question id when questions reappear.
- Restored answers appear in UI or unsupported gaps are explicitly handled.
- Completion payload includes only visible answers.
- Complete validates and syncs visible free-text values before submitting.
- Complete scrolls to first validation error instead of completing when invalid.
- Free-text Submit appears only for current/last free-text questions needing
  explicit submission.
- Conditional free-text branch changes require explicit Submit.
- Non-conditional earlier free-text edits do not remove later questions.
- Tests cover cache, restore, Complete validation, Submit visibility,
  stale-answer prevention, and keyboard Done behavior.
