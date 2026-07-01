# Questionnaire Task


<!-- GENERATED:FIELDS START -->
| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `type` | `String` | Yes | - | Fixed value `questionnaire`. |
| `id` | `String` | Yes | - | Unique task identifier. |
| `title` | `String?` | No | - | Short display title. |
| `header` | `String?` | No | - | Optional header text shown above the task. |
| `footer` | `String?` | No | - | Optional footer text shown below the task. |
| `schedule` | `Schedule` | No | - | When this task is presented to the participant. |
| `questions` | `StudyUQuestionnaire` | No | `StudyUQuestionnaire()` | The ordered list of questions in this task. |
<!-- GENERATED:FIELDS END -->

<!-- GENERATED:DISCRIMINATORS START -->
| Field | Value(s) |
|-------|---------|
| `type` | `questionnaire` |
<!-- GENERATED:DISCRIMINATORS END -->
