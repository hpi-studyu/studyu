import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurement_selection_dialog.dart';
import 'package:studyu_designer_v2/localization/app_localizations_en.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

void main() {
  setUpAll(() => AppTranslation.setForTesting(AppLocalizationsEn()));

  testWidgets('hides nutrition after it has been configured', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MeasurementSelectionDialog(canAddNutrition: false),
      ),
    );

    expect(find.text('Nutrition tracking'), findsNothing);
    expect(find.text('Survey'), findsOneWidget);
    expect(find.text('Survey from template'), findsOneWidget);
  });

  testWidgets('returns the selected survey creation method', (tester) async {
    MeasurementSelection? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await showDialog<MeasurementSelection>(
                context: context,
                builder: (_) =>
                    const MeasurementSelectionDialog(canAddNutrition: true),
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Survey from template'));
    await tester.pumpAndSettle();

    expect(result, MeasurementSelection.template);
  });
}
