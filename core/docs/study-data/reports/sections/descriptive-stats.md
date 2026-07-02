# Descriptive Stats Section

## Description

`DescriptiveStatsSection` reports summary statistics for a referenced result property.


<!-- GENERATED:FIELDS START -->
| Field            | Type                                                    | Required | Description                                                         |
|------------------|---------------------------------------------------------|----------|---------------------------------------------------------------------|
| `type`           | `String`                                                | Yes      | Fixed value `descriptive_stats`.                                    |
| `id`             | `String`                                                | Yes      | Unique section identifier (UUID).                                   |
| `title`          | `String?`                                               | No       | Display title of this report section.                               |
| `description`    | `String?`                                               | No       | Optional description.                                               |
| `resultProperty` | [`DataReference<num>?`](../../shared/data-reference.md) | No       | Reference to the result property for which statistics are computed. |
<!-- GENERATED:FIELDS END -->

<!-- GENERATED:DISCRIMINATORS START -->
| Field | Value(s) |
|-------|---------|
| `type` | `descriptive_stats` |
<!-- GENERATED:DISCRIMINATORS END -->
