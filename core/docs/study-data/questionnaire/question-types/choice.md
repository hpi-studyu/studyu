# Choice Question

## Description

`ChoiceQuestion` asks participants to choose one or more configured answers.


<!-- GENERATED:FIELDS START -->
| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `type` | `String` | Yes | - | Fixed value `choice`. |
| `id` | `String` | Yes | - | Unique question identifier (UUID). |
| `prompt` | `String?` | No | - | The question text. |
| `rationale` | `String?` | No | - | Optional explanation. |
| `conditional` | `QuestionConditional<V>?` | No | - | Optional display condition. |
| `multiple` | `bool` | No | `false` | Whether multiple answers can be selected simultaneously. |
| `choices` | `List<Choice>` | No | `[]` | List of answer options the participant may select. |
<!-- GENERATED:FIELDS END -->

<!-- GENERATED:DISCRIMINATORS START -->
| Field | Value(s) |
|-------|---------|
| `type` | `choice` |
<!-- GENERATED:DISCRIMINATORS END -->
