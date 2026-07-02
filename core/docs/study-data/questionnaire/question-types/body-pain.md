# Body Pain Models

## Description

Body pain models describe pain locations and intensity values used by pain questions.


<!-- GENERATED:FIELDS START -->

| Field       | Type                             | Required | Default                                                                                           | Description                                      |
|-------------|----------------------------------|----------|---------------------------------------------------------------------------------------------------|--------------------------------------------------|
| `painLevel` | `int`                            | Yes      | `0, type: json['type'] == null ? null : PainType.fromJson(json['type'] as Map<String, dynamic>))` | Numeric pain intensity value for a body part.    |
| `type`      | [`PainType?`](body-pain.md)      | No       | -                                                                                                 | Pain type identifier string.                     |
| `id`        | `String`                         | Yes      | -                                                                                                 | Unique identifier.                               |
| `name`      | `String`                         | Yes      | -                                                                                                 | Display name of the body part or pain type.      |
| `pain`      | [`BodyPain`](body-pain.md)       | Yes      | -                                                                                                 | Pain record associated with a body region.       |
| `children`  | [`List<BodyPart>`](body-pain.md) | Yes      | `const [])`                                                                                       | Child body parts nested within this body region. |
| `parts`     | [`List<BodyPart>`](body-pain.md) | Yes      | `const [])`                                                                                       | List of body parts making up this body model.    |
| `name`      | `String`                         | Yes      | -                                                                                                 | Display name of the body part or pain type.      |
<!-- GENERATED:FIELDS END -->
