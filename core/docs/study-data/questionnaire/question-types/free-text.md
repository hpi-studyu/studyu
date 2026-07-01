# Free Text Question


<!-- GENERATED:FIELDS START -->
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | `String` | Yes | Fixed value `free_text`. |
| `id` | `String` | Yes | Unique question identifier (UUID). |
| `prompt` | `String?` | No | The question text. |
| `rationale` | `String?` | No | Optional explanation. |
| `conditional` | `QuestionConditional<V>?` | No | Optional display condition. |
| `lengthRange` | `List<int>` | Yes | Optional min/max character count constraints on the answer. |
| `textType` | `FreeTextQuestionType` | Yes | Text input type (e.g. plain text, email, phone number). |
| `customTypeExpression` | `String?` | No | Regex or expression used when `textType` is set to `custom`. |
<!-- GENERATED:FIELDS END -->

<!-- GENERATED:DISCRIMINATORS START -->
| Field | Value(s) |
|-------|---------|
| `type` | `freeText` |
<!-- GENERATED:DISCRIMINATORS END -->
