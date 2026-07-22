import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/study/nutrition/recipe_builder_screen.dart';
import 'package:studyu_app/widgets/nutrition_summary_card.dart';
import 'package:studyu_core/core.dart';

Widget testApp(Widget home) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);

NutritionProfile zeroNutrition() => NutritionProfile(
  energyKcal: 0,
  protein: 0,
  carbs: 0,
  fat: 0,
  sugars: 0,
  fiber: 0,
  saturatedFat: 0,
  transFat: 0,
  cholesterol: 0,
  sodium: 0,
  waterContent: 0,
  micros: const {},
);

void main() {
  testWidgets('nutrition summary is compact and expands without hiding zeros', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      testApp(
        Scaffold(
          body: SingleChildScrollView(
            child: NutritionSummaryCard(
              nutrition: zeroNutrition(),
              title: 'Meal Nutrition',
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Meal Nutrition'), findsOneWidget);
    expect(find.text('0 kcal'), findsOneWidget);
    expect(find.text('0.0g'), findsNWidgets(3));
    expect(find.bySemanticsLabel(RegExp('0 kcal')), findsWidgets);
    expect(find.bySemanticsLabel(RegExp('0\\.0g')), findsWidgets);
    expect(find.text('No data yet'), findsNothing);
    expect(find.text('Detailed Nutrients'), findsNothing);

    final summaryTile = find.byType(ListTile).first;
    await tester.tap(summaryTile);
    await tester.pumpAndSettle();

    expect(find.text('0 kcal'), findsOneWidget);
    expect(find.text('0.0g'), findsNWidgets(3));
    expect(find.text('No data yet'), findsOneWidget);
    expect(find.text('Detailed Nutrients'), findsOneWidget);

    await tester.tap(summaryTile);
    await tester.pumpAndSettle();

    expect(find.text('0 kcal'), findsOneWidget);
    expect(find.text('0.0g'), findsNWidgets(3));
    expect(find.text('No data yet'), findsNothing);
    expect(find.text('Detailed Nutrients'), findsNothing);

    semantics.dispose();
  });

  testWidgets('recipe builder uses the shared collapsed nutrition summary', (
    tester,
  ) async {
    await tester.pumpWidget(testApp(const RecipeBuilderScreen()));
    await tester.pump();

    await tester.tap(find.byTooltip('Quick Add'));
    await tester.pumpAndSettle();

    final nameField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.labelText == 'Name *',
    );
    final caloriesField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.decoration?.labelText == 'Calories (kcal)',
    );
    await tester.enterText(nameField, 'Test ingredient');
    await tester.enterText(caloriesField, '100');
    final addButton = find.widgetWithText(FilledButton, 'Add');
    await tester.ensureVisible(addButton);
    await tester.pumpAndSettle();
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    expect(find.byType(NutritionSummaryCard), findsOneWidget);
    expect(find.text('Nutrition per Serving'), findsOneWidget);
    expect(find.text('1 serving'), findsOneWidget);
    expect(find.text('100 kcal'), findsOneWidget);
    expect(find.text('0.0g'), findsNWidgets(3));
    expect(find.text('No data yet'), findsNothing);
  });
}
