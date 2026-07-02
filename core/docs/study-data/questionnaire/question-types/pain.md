# Pain Question

## Description

`PainQuestion` records pain information through body pain models.


<!-- GENERATED:FIELDS START -->
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | `String` | Yes | Fixed value `pain`. |
| `id` | `String` | Yes | Unique question identifier (UUID). |
| `prompt` | `String?` | No | The question text. |
| `rationale` | `String?` | No | Optional explanation. |
| `conditional` | `QuestionConditional<V>?` | No | Optional display condition. |
<!-- GENERATED:FIELDS END -->

<!-- GENERATED:DISCRIMINATORS START -->
| Field | Value(s) |
|-------|---------|
| `type` | `pain` |
<!-- GENERATED:DISCRIMINATORS END -->
