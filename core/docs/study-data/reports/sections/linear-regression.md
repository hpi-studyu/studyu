# Linear Regression Section

## Description

`LinearRegressionSection` reports a trend for a referenced numeric result property.


<!-- GENERATED:FIELDS START -->
| Field            | Type                                                                  | Required | Default | Description                                                          |
|------------------|-----------------------------------------------------------------------|----------|---------|----------------------------------------------------------------------|
| `type`           | `String`                                                              | Yes      | -       | Fixed value `linearRegression`.                                      |
| `id`             | `String`                                                              | Yes      | -       | Unique section identifier (UUID).                                    |
| `title`          | `String?`                                                             | No       | -       | Display title of this report section.                                |
| `description`    | `String?`                                                             | No       | -       | Optional description.                                                |
| `resultProperty` | [`DataReference<num>?`](../../shared/data-reference.md)               | No       | -       | Reference to the numeric result property being analyzed.             |
| `alpha`          | `double`                                                              | No       | `0.05`  | Significance threshold for the regression (default 0.05).            |
| `improvement`    | [`ImprovementDirection?`](../../shared/enums.md#improvementdirection) | No       | -       | Direction that counts as improvement. One of `positive`, `negative`. |
<!-- GENERATED:FIELDS END -->

<!-- GENERATED:DISCRIMINATORS START -->
| Field | Value(s) |
|-------|---------|
| `type` | `linearRegression` |
<!-- GENERATED:DISCRIMINATORS END -->
