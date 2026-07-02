# Pain Question

## Description

`PainQuestion` records pain information through body pain models.


<!-- GENERATED:FIELDS START -->
| Field         | Type                                                              | Required | Description                                              |
|---------------|-------------------------------------------------------------------|----------|----------------------------------------------------------|
| `type`        | `String`                                                          | Yes      | Fixed value `pain`.                                      |
| `id`          | `String`                                                          | Yes      | Unique question identifier (UUID).                       |
| `prompt`      | `String?`                                                         | No       | The question text.                                       |
| `rationale`   | `String?`                                                         | No       | Optional explanation.                                    |
| `conditional` | [`QuestionConditional<V>?`](../../shared/question-conditional.md) | No       | Optional display condition using a question conditional. |
<!-- GENERATED:FIELDS END -->

<!-- GENERATED:DISCRIMINATORS START -->
| Field | Value(s) |
|-------|---------|
| `type` | `pain` |
<!-- GENERATED:DISCRIMINATORS END -->
