# Annotated Scale Question


<!-- GENERATED:FIELDS START -->
| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `type` | `String` | Yes |  | Fixed value `annotated_scale`. |
| `id` | `String` | Yes |  | Unique question identifier (UUID). |
| `prompt` | `String?` | No |  | The question text. |
| `rationale` | `String?` | No |  | Optional explanation. |
| `conditional` | `QuestionConditional<V>?` | No |  | Optional display condition. |
| `minimum` | `double` | No |  | Minimum numeric value. |
| `maximum` | `double` | No |  | Maximum numeric value. |
| `step` | `double` | No |  | Step size between selectable values. |
| `annotations` | `List<Annotation>` | No | `[]` | Labeled tick marks along the scale. |
| `initial` | `unknown` | No |  | Optional initial value. |
<!-- GENERATED:FIELDS END -->

<!-- GENERATED:DISCRIMINATORS START -->
| Field | Value(s) |
|-------|---------|
| `type` | `annotatedScale` |
<!-- GENERATED:DISCRIMINATORS END -->
