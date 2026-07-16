# Flutter widget previews

This document records the investigation from [issue #839](https://github.com/hpi-studyu/studyu/issues/839).

## Decision

StudyU can use Flutter's Widget Previewer across the Pub workspace with the pinned Flutter 3.44.6 SDK. Run one preview server from the repository root. The server discovers previews in `app`, `designer_v2`, and `flutter_common`.

Add previews in stages rather than trying to cover every screen in one change. Start with reusable, data-light widgets. Add screens after their state and service dependencies have small preview fixtures.

## Verified baseline

The investigation used Flutter 3.44.6 and Dart 3.12.2 from `.fvmrc`.

A temporary `@Preview` function was added under `lib/` in each Flutter package. Running the previewer from the repository root generated one scaffold that imported all three packages and loaded all three previews:

- `studyu_app`
- `studyu_designer_v2`
- `studyu_flutter_common`

The temporary files were removed after the check.

Flutter's current tool implementation adds the root project and every workspace project as path dependencies of the generated preview scaffold. This is the Pub workspace support fixed after [flutter/flutter#169268](https://github.com/flutter/flutter/issues/169268).

## Applicable packages

The counts below are a source scan of non-generated Dart files that directly declare common Flutter widget base classes. They identify scope, not a preview coverage target.

| Package | Widget-bearing files | Recommendation |
| --- | ---: | --- |
| `app` | 58 | Preview reusable widgets under `lib/widgets/` first, then leaf sections under `lib/screens/`. |
| `designer_v2` | 107 | Preview `lib/common_views/` first, then data-light feature widgets. |
| `flutter_common` | 1 | Add a preview only when `RetryFutureBuilder` has a visual state worth reviewing. |
| `core` | 0 | No previews. The package has no Flutter dependency. |

Good first candidates include:

- App questionnaire controls, report widgets, `InterventionCard`, `SelectableButton`, `RoundCheckbox`, and `StudyTile`.
- Designer buttons, badges, banners, form labels, layouts, search controls, tables, and status indicators under `common_views`.

Defer widgets that immediately call camera, audio recording, file, URL, Supabase, or other platform and service APIs. Preview their pure visual children instead, or inject fake state before adding a preview.

## Preview structure

Keep preview functions under each package's `lib/previews/` directory. Mirror the source layout so a component and its preview are easy to pair.

```text
app/lib/previews/
  app_preview.dart
  widgets/
    intervention_card_preview.dart
    questionnaire/
      choice_question_widget_preview.dart
  screens/
    study/
      report/
        report_section_container_preview.dart

designer_v2/lib/previews/
  designer_preview.dart
  common_views/
    badge_preview.dart
    primary_button_preview.dart
  features/
    dashboard/
      study_status_badge_preview.dart
```

`app_preview.dart` and `designer_preview.dart` should each define that package's theme and localization callbacks. Keep the implementations separate because the apps use different theme and state systems.

Do not add a central registry. The previewer discovers annotations. Do not add parameterless constructors to production widgets for previewing; use public top-level functions that build widgets with fixture data.

### Naming

Use these conventions:

- File: `<source_file>_preview.dart`
- Function: `<widgetName><state>Preview`, for example `choiceQuestionWidgetMultiplePreview`
- Group: `<Package> / <Feature>`, for example `App / Questionnaire`
- Display name: `<Widget> / <state>`, for example `ChoiceQuestionWidget / multiple`

Example:

```dart
@Preview(
  group: 'App / Questionnaire',
  name: 'ChoiceQuestionWidget / multiple',
)
Widget choiceQuestionWidgetMultiplePreview() => ChoiceQuestionWidget(
  // Minimal fixture data.
);
```

Use multiple `@Preview` annotations only for states that reviewers compare often, such as light and dark themes, selected and unselected states, or narrow and wide constraints.

## Shared preview configuration

Each app needs a small custom `Preview` annotation or public callbacks for:

- its existing `ThemeData`;
- English localization delegates and supported locales;
- a `Material` or `Scaffold` wrapper when the component requires one.

Add Riverpod `ProviderScope`, Provider overrides, reactive form controls, or router state in the individual preview that needs them. A global wrapper with every application dependency would start services and make simple previews fragile.

Use fixture objects with no network, storage, clock, or platform side effects. Keep feature-specific fixtures beside their preview files until two previews need the same fixture.

## Running previews locally

Install workspace dependencies, then start one server from the repository root:

```sh
rtk fvm dart pub get
rtk fvm flutter widget-preview start
```

Omit the `rtk` prefix when it is not installed. Chrome must be available. Flutter 3.38 and newer can also start the previewer from supported Android Studio, IntelliJ, and VS Code versions.

Stop the server with `Ctrl+C`. Clear generated preview state after SDK or scaffold problems:

```sh
rtk fvm flutter widget-preview clean
```

A later implementation can add a `melos previews` alias, but the direct root command already covers the complete workspace.

## CI recommendation

Keep the preview server out of required CI for the first implementation.

`flutter widget-preview start` runs an interactive development server and does not provide a supported one-shot validation mode. Flutter exposes `--headless`, `--machine`, and `--no-devtools`, but lists them with options used to test the Flutter tool itself. A CI job would need to wait for `Done loading previews.` and terminate the server, which couples StudyU to unstable tool output.

The existing formatter and analyzer checks will still compile and lint preview source files because they live under `lib/`. Add a bounded headless smoke job only if preview-specific regressions become common or Flutter adds a supported validation command.

Widget tests and golden tests remain the CI tools for behavior and visual regression checks. Previews serve the local development loop.

## Current limitations

- Flutter marks the preview annotation API as unstable. Keep preview helpers small and update them with the pinned SDK.
- Preview targets must be public top-level functions, public static methods, or public widget constructors or factories without required arguments. Annotation arguments must be constant, and callback names must be public.
- The previewer runs on Flutter Web. Calls into `dart:io`, `dart:ffi`, or native plugin APIs fail when invoked.
- `dart:ui` asset loaders need package-qualified paths such as `packages/studyu_app/assets/...`.
- Unconstrained widgets receive previewer defaults. Set an explicit `Size` for layout-sensitive components.
- Preview functions outside `lib/` crashed Flutter 3.44.6 during this investigation in `PreviewCodeGenerator._buildPreviewsLsp`. Keep StudyU previews under `lib/previews/` even though [flutter/flutter#178651](https://github.com/flutter/flutter/issues/178651) is marked fixed.
- The IDE previewer supports one project or Pub workspace at a time. Flutter tracks broader multi-project IDE support in [flutter/flutter#173550](https://github.com/flutter/flutter/issues/173550).

## Recommended follow-ups

1. [#890: Add initial app widget previews](https://github.com/hpi-studyu/studyu/issues/890)
2. [#891: Add initial designer widget previews](https://github.com/hpi-studyu/studyu/issues/891)
3. Revisit CI only after the first two changes establish whether analyzer coverage is enough.

## Sources

- [Flutter Widget Previewer documentation](https://docs.flutter.dev/tools/widget-previewer)
- [`Preview` API in Flutter 3.44.6](https://github.com/flutter/flutter/blob/ee80f08bbf97172ec030b8751ceab557177a34a6/packages/flutter/lib/src/widget_previews/widget_previews.dart#L28-L178)
- [Flutter workspace dependency setup for the generated preview scaffold](https://github.com/flutter/flutter/blob/ee80f08bbf97172ec030b8751ceab557177a34a6/packages/flutter_tools/lib/src/widget_preview/preview_pubspec_builder.dart#L118-L157)
