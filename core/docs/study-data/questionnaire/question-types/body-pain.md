# Body Pain Models

## Description

Body pain models describe pain locations and intensity values used by pain questions.


<!-- GENERATED:FIELDS START -->
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `painLevel` | `int` | Yes | Numeric pain intensity value for a body part. |
| `type` | `PainType?` | No | Pain type identifier string. |
| `id` | `String` | Yes | Unique identifier. |
| `name` | `String` | Yes | Display name of the body part or pain type. |
| `pain` | `BodyPain` | Yes | List of pain records associated with a body region. |
| `children` | `List<BodyPart>` | Yes | Child body parts nested within this body region. |
| `parts` | `List<BodyPart>` | Yes | List of body parts making up this body model. |
<!-- GENERATED:FIELDS END -->
