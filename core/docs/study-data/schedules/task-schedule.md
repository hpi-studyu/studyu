# Schedule

## Description

`Schedule` defines when a task is available and when reminders fire.


<!-- GENERATED:FIELDS START -->
| Field               | Type                                                        | Required | Default                                                                                              | Description                                                       |
|---------------------|-------------------------------------------------------------|----------|------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------|
| `completionPeriods` | `List<CompletionPeriod>`                                    | No       | `[CompletionPeriod.noId(unlockTime: StudyUTimeOfDay(hour: 8), lockTime: StudyUTimeOfDay(hour: 20))]` | Time windows within a day during which the task can be completed. |
| `reminders`         | [`List<StudyUTimeOfDay>`](../shared/scalars.md#time-of-day) | No       | `[]`                                                                                                 | Optional reminder times for this task.                            |
<!-- GENERATED:FIELDS END -->

## CompletionPeriod

Each entry in `completionPeriods` is a nested completion-period object.

```json
{
  "id": "morning-window",
  "unlockTime": "8:00",
  "lockTime": "12:00"
}
```

- `id`: unique completion-period identifier.
- `unlockTime`: local time when the task window opens.
- `lockTime`: local time when the task window closes.
