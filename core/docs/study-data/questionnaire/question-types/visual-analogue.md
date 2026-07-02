# Visual Analogue Question

## Description

`VisualAnalogueQuestion` records a slider value with endpoint labels and colors.


<!-- GENERATED:FIELDS START -->
| Field               | Type                                                              | Required | Default      | Description                                              |
|---------------------|-------------------------------------------------------------------|----------|--------------|----------------------------------------------------------|
| `type`              | `String`                                                          | Yes      | -            | Fixed value `visualAnalogue`.                            |
| `id`                | `String`                                                          | Yes      | -            | Unique question identifier (UUID).                       |
| `prompt`            | `String?`                                                         | No       | -            | The question text.                                       |
| `rationale`         | `String?`                                                         | No       | -            | Optional explanation.                                    |
| `conditional`       | [`QuestionConditional<V>?`](../../shared/question-conditional.md) | No       | -            | Optional display condition using a question conditional. |
| `minimum`           | `double`                                                          | No       | -            | Minimum numeric value.                                   |
| `maximum`           | `double`                                                          | No       | -            | Maximum numeric value.                                   |
| `step`              | `double`                                                          | No       | -            | Step size.                                               |
| `minimumColor`      | `int`                                                             | No       | `0xFF0000FF` | ARGB color integer for the left/minimum end.             |
| `maximumColor`      | `int`                                                             | No       | `0xFFFF0000` | ARGB color integer for the right/maximum end.            |
| `minimumAnnotation` | `String`                                                          | No       | `''`         | Label shown at the minimum end.                          |
| `maximumAnnotation` | `String`                                                          | No       | `''`         | Label shown at the maximum end.                          |
| `initial`           | `unknown`                                                         | No       | -            | Optional initial value.                                  |
<!-- GENERATED:FIELDS END -->

<!-- GENERATED:DISCRIMINATORS START -->
| Field | Value(s) |
|-------|---------|
| `type` | `visualAnalogue` |
<!-- GENERATED:DISCRIMINATORS END -->
