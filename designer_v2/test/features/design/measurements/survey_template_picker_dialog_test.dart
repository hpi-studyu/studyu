@TestOn('browser')
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurements_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurements_form_data.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey_template_picker_dialog.dart';
import 'package:studyu_designer_v2/localization/app_localizations_en.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

void main() {
  setUpAll(() => AppTranslation.setForTesting(AppLocalizationsEn()));

  testWidgets('single template explains its result and dialog can cancel', (
    tester,
  ) async {
    final measurements = _measurements();
    await _pumpPicker(tester, measurements);

    expect(find.text('Survey Templates'), findsOneWidget);
    expect(
      find.text(
        'Creates one editable survey with all questions from this template.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();

    expect(find.text('Open templates'), findsOneWidget);
    expect(
      measurements.measurementViewModelsCollection.retrievableViewModels,
      isEmpty,
    );
  });

  testWidgets('staged single template is shown as added and cannot reapply', (
    tester,
  ) async {
    final measurements = _measurements();
    measurements.applyTemplate(SurveyTemplateRegistry.findById('ffq_26')!);

    await _pumpPicker(tester, measurements);

    expect(find.text('Added'), findsOneWidget);
    expect(find.text('Apply'), findsNothing);
  });
}

Future<void> _pumpPicker(
  WidgetTester tester,
  MeasurementsFormViewModel measurements,
) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) =>
                    SurveyTemplatePickerDialog(formViewModel: measurements),
              ),
              child: const Text('Open templates'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open templates'));
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
