# Intervention


<!-- GENERATED:FIELDS START -->
| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `id` | `String` | Yes | - | Unique intervention identifier (UUID). |
| `name` | `String?` | No | - | Display name of the intervention arm. |
| `description` | `String?` | No | - | Optional description of what participants do in this arm. |
| `icon` | `String` | No | `''` | Material icon name for this intervention. |
| `tasks` | `List<InterventionTask>` | No | `[]` | List of tasks participants perform during each day of this intervention. |
<!-- GENERATED:FIELDS END -->
