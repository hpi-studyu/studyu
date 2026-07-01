# Gauge Comparison Section


<!-- GENERATED:FIELDS START -->
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | `String` | Yes | Fixed value `gauge_comparison`. |
| `id` | `String` | Yes | Unique section identifier (UUID). |
| `title` | `String?` | No | Display title of this report section. |
| `description` | `String?` | No | Optional description. |
| `resultProperty` | `DataReference<num>?` | No | Reference to the numeric result property shown in the gauge. |
<!-- GENERATED:FIELDS END -->

<!-- GENERATED:DISCRIMINATORS START -->
| Field | Value(s) |
|-------|---------|
| `type` | `gauge_comparison` |
<!-- GENERATED:DISCRIMINATORS END -->
