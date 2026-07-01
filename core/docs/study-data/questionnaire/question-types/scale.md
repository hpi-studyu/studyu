# Scale Question


<!-- GENERATED:FIELDS START -->
| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `type` | `String` | Yes |  | Fixed value `scale`. |
| `id` | `String` | Yes |  | Unique question identifier (UUID). |
| `prompt` | `String?` | No |  | The question text. |
| `rationale` | `String?` | No |  | Optional explanation. |
| `conditional` | `QuestionConditional<V>?` | No |  | Optional display condition. |
| `minimum` | `double` | No |  | Minimum numeric value on the scale. |
| `maximum` | `double` | No |  | Maximum numeric value on the scale. |
| `step` | `double` | No |  | Step size between selectable values. `0` means auto-generated intermediate values. |
| `annotations` | `List<Annotation>` | No | `[]` | Labeled tick marks along the scale. |
| `minColor (min_color)` | `int?` | No |  | Optional ARGB color integer for the minimum end of the scale. |
| `maxColor (max_color)` | `int?` | No |  | Optional ARGB color integer for the maximum end of the scale. |
| `initial` | `unknown` | No |  | Optional initial value shown when the question first appears. |
<!-- GENERATED:FIELDS END -->

<!-- GENERATED:DISCRIMINATORS START -->
| Field | Value(s) |
|-------|---------|
| `type` | `scale` |
<!-- GENERATED:DISCRIMINATORS END -->
