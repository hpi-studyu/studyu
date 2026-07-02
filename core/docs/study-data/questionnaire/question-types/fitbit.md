# Fitbit Question

## Description

`FitbitQuestion` requests Fitbit data types used by the study.


<!-- GENERATED:FIELDS START -->
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | `String` | Yes | Fixed value `fitbit`. |
| `id` | `String` | Yes | Unique question identifier (UUID). |
| `prompt` | `String?` | No | The question text. |
| `rationale` | `String?` | No | Optional explanation. |
| `conditional` | `QuestionConditional<V>?` | No | Optional display condition. |
| `types` | `List<FitbitQuestionType>` | Yes | List of Fitbit data types to collect (e.g. steps, sleep, heart rate). |
<!-- GENERATED:FIELDS END -->

<!-- GENERATED:DISCRIMINATORS START -->
| Field | Value(s) |
|-------|---------|
| `type` | `FitbitQuestion` |
<!-- GENERATED:DISCRIMINATORS END -->
