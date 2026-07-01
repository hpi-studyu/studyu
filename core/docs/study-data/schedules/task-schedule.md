# Schedule


<!-- GENERATED:FIELDS START -->
| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `completionPeriods` | `List<CompletionPeriod>` | No | `[CompletionPeriod.noId(unlockTime: StudyUTimeOfDay(hour: 8), lockTime: StudyUTimeOfDay(hour: 20))]` | Time windows within a day during which the task can be completed. |
| `reminders` | `List<StudyUTimeOfDay>` | No | `[]` | Optional reminder times for this task. |
<!-- GENERATED:FIELDS END -->
