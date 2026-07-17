import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/measurements/nutrition/nutrition_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/nutrition/nutrition_form_view.dart';
import 'package:studyu_designer_v2/localization/app_localizations_en.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

void main() {
  setUpAll(() => AppTranslation.setForTesting(AppLocalizationsEn()));

  testWidgets('add meal type shows a new input', (tester) async {
    final formViewModel = NutritionFormViewModel(
      study: Study.withId('study-1'),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ReactiveForm(
              formGroup: formViewModel.form,
              child: NutritionFormView(formViewModel: formViewModel),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Add meal type'));
    await tester.pump();

    expect(formViewModel.customMealTypesControl.controls, hasLength(1));
    expect(find.text('Meal type 1'), findsOneWidget);
    expect(find.byTooltip('Remove'), findsOneWidget);
  });
}
