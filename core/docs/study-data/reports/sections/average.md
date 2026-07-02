# Average Section

## Description

`AverageSection` reports an average for a referenced numeric result property.


<!-- GENERATED:FIELDS START -->
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | `String` | Yes | Fixed value `average`. |
| `id` | `String` | Yes | Unique section identifier (UUID). |
| `title` | `String?` | No | Display title of this report section. |
| `description` | `String?` | No | Optional description of what this section shows. |
| `aggregate` | `TemporalAggregation?` | No | Temporal aggregation strategy (e.g. per-day mean). |
| `resultProperty` | `DataReference<num>?` | No | Reference to the numeric result property being averaged. |
<!-- GENERATED:FIELDS END -->

<!-- GENERATED:DISCRIMINATORS START -->
| Field | Value(s) |
|-------|---------|
| `type` | `average` |
<!-- GENERATED:DISCRIMINATORS END -->
