# Subject Progress

> **Note:** These are Supabase join rows, not portable study-definition fields. Do not include them in study JSON exported from the designer.


<!-- GENERATED:FIELDS START -->
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `completedAt (completed_at)` | `DateTime?` | No | UTC timestamp when the task was completed. |
| `subjectId (subject_id)` | `String` | Yes | ID of the study subject who completed the task. |
| `interventionId (intervention_id)` | `String` | Yes | ID of the active intervention phase when the task was completed. |
| `taskId (task_id)` | `String` | Yes | ID of the task that was completed. |
| `resultType (result_type)` | `String` | Yes | String discriminator for the result payload type. |
| `result` | `Result<dynamic>` | Yes | The serialized task result payload. |
<!-- GENERATED:FIELDS END -->
