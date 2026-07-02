# Image Capturing Question

## Description

`ImageCapturingQuestion` asks participants to submit an image.


<!-- GENERATED:FIELDS START -->
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | `String` | Yes | Fixed value `image_capturing`. |
| `id` | `String` | Yes | Unique question identifier (UUID). |
| `prompt` | `String?` | No | The question text. |
| `rationale` | `String?` | No | Optional explanation. |
| `conditional` | `QuestionConditional<V>?` | No | Optional display condition. |
<!-- GENERATED:FIELDS END -->

<!-- GENERATED:DISCRIMINATORS START -->
| Field | Value(s) |
|-------|---------|
| `type` | `ImageCapturingQuestion` |
<!-- GENERATED:DISCRIMINATORS END -->
