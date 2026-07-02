# Numeric Result

## Description

`NumericResult` defines an exported numeric result property.


<!-- GENERATED:FIELDS START -->
| Field            | Type                                                | Required | Description                                             |
|------------------|-----------------------------------------------------|----------|---------------------------------------------------------|
| `type`           | `String`                                            | Yes      | Fixed value `numeric`.                                  |
| `id`             | `String`                                            | Yes      | Unique result identifier (UUID).                        |
| `filename`       | `String`                                            | No       | CSV export filename for this result type.               |
| `resultProperty` | [`DataReference<num>`](../shared/data-reference.md) | Yes      | Reference to the numeric property this result captures. |
<!-- GENERATED:FIELDS END -->

<!-- GENERATED:DISCRIMINATORS START -->
| Field | Value(s) |
|-------|---------|
| `type` | `numeric` |
<!-- GENERATED:DISCRIMINATORS END -->
