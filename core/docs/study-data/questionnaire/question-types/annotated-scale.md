# Annotated Scale Question

## Description

`AnnotatedScaleQuestion` records a numeric scale answer with labelled values.


<!-- GENERATED:FIELDS START -->
| Field         | Type                                                              | Required | Default | Description                                              |
|---------------|-------------------------------------------------------------------|----------|---------|----------------------------------------------------------|
| `type`        | `String`                                                          | Yes      | -       | Fixed value `annotatedScale`.                            |
| `id`          | `String`                                                          | Yes      | -       | Unique question identifier (UUID).                       |
| `prompt`      | `String?`                                                         | No       | -       | The question text.                                       |
| `rationale`   | `String?`                                                         | No       | -       | Optional explanation.                                    |
| `conditional` | [`QuestionConditional<V>?`](../../shared/question-conditional.md) | No       | -       | Optional display condition using a question conditional. |
| `minimum`     | `double`                                                          | No       | -       | Minimum numeric value.                                   |
| `maximum`     | `double`                                                          | No       | -       | Maximum numeric value.                                   |
| `step`        | `double`                                                          | No       | -       | Step size between selectable values.                     |
| `annotations` | [`List<Annotation>`](../nested-objects.md)                        | No       | `[]`    | Labeled tick marks along the scale.                      |
| `initial`     | `unknown`                                                         | No       | -       | Optional initial value.                                  |
<!-- GENERATED:FIELDS END -->

<!-- GENERATED:DISCRIMINATORS START -->
| Field | Value(s) |
|-------|---------|
| `type` | `annotatedScale` |
<!-- GENERATED:DISCRIMINATORS END -->
