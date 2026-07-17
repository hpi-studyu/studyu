@TestOn('browser')
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/dialog.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurement_picker_dialog.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurements_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurements_form_data.dart';
import 'package:studyu_designer_v2/localization/app_localizations_en.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

void main() {
  setUpAll(() => AppTranslation.setForTesting(AppLocalizationsEn()));

  testWidgets('uses the standard dialog and groups predefined measurements', (
    tester,
  ) async {
    await _pumpPicker(tester, _measurements());

    expect(find.byType(StandardDialog), findsOneWidget);
    expect(find.text('Add measurement'), findsOneWidget);
    expect(find.text('Custom survey'), findsOneWidget);
    expect(find.text('Predefined measurements'), findsOneWidget);
    expect(find.text('All'), findsNWidgets(2));
    expect(find.text('Nutrition'), findsOneWidget);
    expect(find.text('Nutrition tracking'), findsOneWidget);
    expect(find.text('Food Frequency Questionnaire (FFQ)'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Open measurements'), findsOneWidget);
  });

  testWidgets('returns custom survey selection after dismissing the dialog', (
    tester,
  ) async {
    MeasurementSelection? result;
    await _pumpPicker(
      tester,
      _measurements(),
      onResult: (value) => result = value,
    );

    await tester.tap(find.text('Custom survey'));
    await tester.pumpAndSettle();

    expect(result, MeasurementSelection.blankSurvey);
    expect(find.byType(StandardDialog), findsNothing);
  });

  testWidgets('shows nutrition as added when the singleton already exists', (
    tester,
  ) async {
    await _pumpPicker(tester, _measurements(), canAddNutrition: false);

    expect(find.text('Nutrition tracking'), findsOneWidget);
    expect(find.text('Added'), findsOneWidget);
  });

  testWidgets('single template explains its result and can be added', (
    tester,
  ) async {
    final measurements = _measurements();
    await _pumpPicker(tester, measurements);

    expect(
      find.text(
        'Creates one editable survey with all questions from this template.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Add').last);
    await tester.pumpAndSettle();

    expect(
      measurements.measurementViewModelsCollection.retrievableViewModels,
      hasLength(1),
    );
  });

  testWidgets('staged single template is shown as added and cannot reapply', (
    tester,
  ) async {
    final measurements = _measurements();
    measurements.applyTemplate(SurveyTemplateRegistry.findById('ffq_26')!);

    await _pumpPicker(tester, measurements);

    expect(find.text('Added'), findsOneWidget);
  });
}

Future<void> _pumpPicker(
  WidgetTester tester,
  MeasurementsFormViewModel measurements, {
  bool canAddNutrition = true,
  ValueChanged<MeasurementSelection?>? onResult,
}) async {
  tester.view.physicalSize = const Size(1200, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                final result = await showDialog<MeasurementSelection>(
                  context: context,
                  builder: (_) => MeasurementPickerDialog(
                    formViewModel: measurements,
                    canAddNutrition: canAddNutrition,
                  ),
                );
                onResult?.call(result);
              },
              child: const Text('Open measurements'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open measurements'));
  await tester.pumpAndSettle();
}

MeasurementsFormViewModel _measurements() {
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => const SizedBox.shrink()),
      GoRoute(
        path: '/studies/:studyId/edit/measurements/:measurementId',
        name: studyEditMeasurementRouteName,
        builder: (_, _) => const SizedBox.shrink(),
      ),
    ],
  );
  addTearDown(router.dispose);
  return MeasurementsFormViewModel(
    study: Study.withId('study-1'),
    router: router,
    formData: MeasurementsFormData(measurements: []),
  );
}
