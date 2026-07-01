# Study Subject

> **Note:** These are Supabase join rows, not portable study-definition fields. Do not include them in study JSON exported from the designer.


<!-- GENERATED:FIELDS START -->
| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `id` | `String` | Yes |  | Unique participant identifier (UUID). |
| `studyId (study_id)` | `String` | Yes |  | ID of the study this subject is enrolled in. |
| `userId (user_id)` | `String` | Yes |  | ID of the authenticated user account. |
| `startedAt (started_at)` | `DateTime?` | No |  | UTC timestamp when the participant started the study. |
| `selectedInterventionIds (selected_intervention_ids)` | `List<String>` | Yes |  | Ordered list of intervention IDs assigned to this participant. |
| `inviteCode (invite_code)` | `String?` | No |  | Invite code used to enrol, if any. |
| `isDeleted (is_deleted)` | `bool` | No | `false` | Whether this subject has been soft-deleted. |
<!-- GENERATED:FIELDS END -->
