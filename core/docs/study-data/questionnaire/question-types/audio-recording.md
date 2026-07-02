# Audio Recording Question

## Description

`AudioRecordingQuestion` asks participants to submit an audio recording.


<!-- GENERATED:FIELDS START -->
| Field                         | Type                                                              | Required | Description                                              |
|-------------------------------|-------------------------------------------------------------------|----------|----------------------------------------------------------|
| `type`                        | `String`                                                          | Yes      | Fixed value `AudioRecordingQuestion`.                    |
| `id`                          | `String`                                                          | Yes      | Unique question identifier (UUID).                       |
| `prompt`                      | `String?`                                                         | No       | The question text.                                       |
| `rationale`                   | `String?`                                                         | No       | Optional explanation.                                    |
| `conditional`                 | [`QuestionConditional<V>?`](../../shared/question-conditional.md) | No       | Optional display condition using a question conditional. |
| `maxRecordingDurationSeconds` | `int`                                                             | Yes      | Maximum recording length in seconds.                     |
<!-- GENERATED:FIELDS END -->

<!-- GENERATED:DISCRIMINATORS START -->
| Field | Value(s) |
|-------|---------|
| `type` | `AudioRecordingQuestion` |
<!-- GENERATED:DISCRIMINATORS END -->
