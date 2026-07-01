# Textual Summary Section


<!-- GENERATED:FIELDS START -->
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | `String` | Yes | Fixed value `textual_summary`. |
| `id` | `String` | Yes | Unique section identifier (UUID). |
| `title` | `String?` | No | Display title of this report section. |
| `description` | `String?` | No | Optional description. |
| `resultProperty` | `DataReference<num>?` | No | Reference to the result property summarized in text. |
<!-- GENERATED:FIELDS END -->

<!-- GENERATED:DISCRIMINATORS START -->
| Field | Value(s) |
|-------|---------|
| `type` | `textual_summary` |
<!-- GENERATED:DISCRIMINATORS END -->
