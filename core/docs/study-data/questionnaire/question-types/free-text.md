# Free Text Question

## Description

`FreeTextQuestion` records typed text with optional format limits.


<!-- GENERATED:FIELDS START -->
| Field                  | Type                                                                 | Required | Description                                                  |
|------------------------|----------------------------------------------------------------------|----------|--------------------------------------------------------------|
| `type`                 | `String`                                                             | Yes      | Fixed value `freeText`.                                      |
| `id`                   | `String`                                                             | Yes      | Unique question identifier (UUID).                           |
| `prompt`               | `String?`                                                            | No       | The question text.                                           |
| `rationale`            | `String?`                                                            | No       | Optional explanation.                                        |
| `conditional`          | [`QuestionConditional<V>?`](../../shared/question-conditional.md)    | No       | Optional display condition using a question conditional.     |
| `lengthRange`          | `List<int>`                                                          | Yes      | Optional min/max character count constraints on the answer.  |
| `textType`             | [`FreeTextQuestionType`](../../shared/enums.md#freetextquestiontype) | Yes      | Text input type (e.g. plain text, email, phone number).      |
| `customTypeExpression` | `String?`                                                            | No       | Regex or expression used when `textType` is set to `custom`. |
<!-- GENERATED:FIELDS END -->

<!-- GENERATED:DISCRIMINATORS START -->
| Field | Value(s) |
|-------|---------|
| `type` | `freeText` |
<!-- GENERATED:DISCRIMINATORS END -->
