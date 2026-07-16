import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_designer_v2/features/design/interventions/study_schedule_form_controller_mixin.dart';
import 'package:studyu_designer_v2/features/design/interventions/study_schedule_form_view.dart';
import 'package:studyu_designer_v2/localization/app_localizations_en.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

void main() {
  setUpAll(() => AppTranslation.setForTesting(AppLocalizationsEn()));

  testWidgets('number of cycles handles clamped and empty input', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 1600);
    addTearDown(tester.view.reset);

    final controls = _StudyScheduleTestControls();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: StudyScheduleFormView(formViewModel: controls),
          ),
        ),
      ),
    );

    final cyclesField = find.byType(TextField).at(1);

    await tester.enterText(cyclesField, '21');
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(controls.numCyclesControl.value, 9);

    await tester.enterText(cyclesField, '');
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(controls.numCyclesControl.value, 9);
  });
}

class _StudyScheduleTestControls with StudyScheduleControls {}
