# Date Question

## Description

`DateQuestion` records a date, time, or combined date-time answer.


<!-- GENERATED:FIELDS START -->
| Field                 | Type                                                              | Required | Description                                                             |
|-----------------------|-------------------------------------------------------------------|----------|-------------------------------------------------------------------------|
| `type`                | `String`                                                          | Yes      | Fixed value `date`.                                                     |
| `id`                  | `String`                                                          | Yes      | Unique question identifier (UUID).                                      |
| `prompt`              | `String?`                                                         | No       | The question text.                                                      |
| `rationale`           | `String?`                                                         | No       | Optional explanation.                                                   |
| `conditional`         | [`QuestionConditional<V>?`](../../shared/question-conditional.md) | No       | Optional display condition using a question conditional.                |
| `inputType`           | [`DateInputType`](../../shared/enums.md#dateinputtype)            | Yes      | Input widget style (e.g. date picker, time picker, date+time).          |
| `minDate`             | [`DateTime?`](../../shared/scalars.md#datetime)                   | No       | Optional earliest selectable date.                                      |
| `maxDate`             | [`DateTime?`](../../shared/scalars.md#datetime)                   | No       | Optional latest selectable date.                                        |
| `minTime`             | `String?`                                                         | No       | Optional earliest selectable time.                                      |
| `maxTime`             | `String?`                                                         | No       | Optional latest selectable time.                                        |
| `dateFormatPreset`    | [`DateFormatPreset`](../../shared/enums.md#dateformatpreset)      | Yes      | Preset controlling how the date is formatted for display.               |
| `timeFormatPreset`    | [`TimeFormatPreset`](../../shared/enums.md#timeformatpreset)      | Yes      | Preset controlling how the time is formatted for display.               |
| `defaultOption`       | [`DefaultDateOption`](../../shared/enums.md#defaultdateoption)    | Yes      | Which default value strategy to use (e.g. current date, specific date). |
| `defaultSpecificDate` | [`DateTime?`](../../shared/scalars.md#datetime)                   | No       | Specific date to pre-fill when `defaultOption` is set to a fixed date.  |
| `defaultSpecificTime` | `String?`                                                         | No       | Specific time to pre-fill when `defaultOption` is set to a fixed time.  |
<!-- GENERATED:FIELDS END -->

<!-- GENERATED:DISCRIMINATORS START -->
| Field | Value(s) |
|-------|---------|
| `type` | `date` |
<!-- GENERATED:DISCRIMINATORS END -->
