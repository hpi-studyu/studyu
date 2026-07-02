# Boolean Question

## Description

`BooleanQuestion` asks for a yes or no answer.


<!-- GENERATED:FIELDS START -->
| Field         | Type                                                              | Required | Description                                              |
|---------------|-------------------------------------------------------------------|----------|----------------------------------------------------------|
| `type`        | `String`                                                          | Yes      | Fixed value `boolean`.                                   |
| `id`          | `String`                                                          | Yes      | Unique question identifier (UUID).                       |
| `prompt`      | `String?`                                                         | No       | The question text.                                       |
| `rationale`   | `String?`                                                         | No       | Optional explanation of why this question is asked.      |
| `conditional` | [`QuestionConditional<V>?`](../../shared/question-conditional.md) | No       | Optional display condition using a question conditional. |
<!-- GENERATED:FIELDS END -->

<!-- GENERATED:DISCRIMINATORS START -->
| Field | Value(s) |
|-------|---------|
| `type` | `boolean` |
<!-- GENERATED:DISCRIMINATORS END -->
