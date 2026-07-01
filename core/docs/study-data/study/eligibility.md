# Eligibility Criterion


<!-- GENERATED:FIELDS START -->
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | `String` | Yes | Unique criterion identifier (UUID). |
| `reason` | `String?` | No | Human-readable explanation of why this criterion exists. |
| `condition` | `Expression` | Yes | The expression evaluated against the participant's questionnaire responses to determine eligibility. |
<!-- GENERATED:FIELDS END -->
