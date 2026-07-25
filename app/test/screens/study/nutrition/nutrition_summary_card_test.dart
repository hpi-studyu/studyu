import 'dart:ui' show SemanticsAction;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/study/nutrition/meal_creator_screen.dart';
import 'package:studyu_app/widgets/nutrition_summary_card.dart';
import 'package:studyu_core/core.dart';

Widget testApp(Widget home) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);

void main() {
  testWidgets('nutrition summary distinguishes zero and unavailable values', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final semantics = tester.ensureSemantics();

    final nutrition = NutritionProfile(
      energyKcal: 555,
      protein: 50.4,
      carbs: 30.7,
      fat: 23.9,
      sugars: 0,
      fiber: 3.5,
      saturatedFat: 0,
      transFat: 0,
      cholesterol: 0,
      sodium: 0,
      waterContent: 0,
      micros: const {},
      unavailableNutrients: const {'sugars'},
      unavailableItemCount: 1,
    );

    await tester.pumpWidget(
      testApp(
        Scaffold(
          body: SingleChildScrollView(
            child: NutritionSummaryCard(
              nutrition: nutrition,
              title: 'Today’s nutrition',
              inCard: true,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(Card), findsOneWidget);
    expect(find.text('Today’s nutrition'), findsOneWidget);
    expect(find.text('555 kcal'), findsOneWidget);
    expect(find.text('30.7 g'), findsOneWidget);
    expect(find.text('50.4 g'), findsOneWidget);
    expect(find.text('Energy by macronutrient'), findsOneWidget);
    expect(find.text('Detailed Nutrients'), findsOneWidget);
    expect(find.text('Show'), findsOneWidget);
    expect(find.text('Hide'), findsNothing);
    expect(
      find.textContaining('Some nutrient values are unavailable for 1 item.'),
      findsOneWidget,
    );
    expect(find.text('—'), findsNothing);

    await tester.tap(find.widgetWithText(TextButton, 'Show'));
    await tester.pumpAndSettle();

    expect(find.text('Hide'), findsOneWidget);
    expect(find.text('—'), findsOneWidget);
    expect(find.text('0 g'), findsAtLeastNWidgets(1));

    semantics.dispose();
  });

  testWidgets('recipe builder empty state is passive and fields are unfilled', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(testApp(const MealCreatorScreen()));
    await tester.pump();

    final emptyState = find.text('No foods yet');
    expect(emptyState, findsOneWidget);
    expect(
      find.ancestor(of: emptyState, matching: find.byType(InkWell)),
      findsNothing,
    );
    expect(
      tester
          .getSemantics(emptyState)
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isFalse,
    );

    for (final label in ['Meal Name *', 'Servings *', 'Description']) {
      final field = tester.widget<TextField>(
        find.byWidgetPredicate(
          (widget) =>
              widget is TextField && widget.decoration?.labelText == label,
        ),
      );
      expect(field.decoration?.filled, isNot(true));
      expect(field.decoration?.fillColor, isNull);
    }

    await tester.tap(find.byTooltip('Add food manually'));
    await tester.pumpAndSettle();

    for (final label in ['Name *', 'Qty', 'Calories (kcal)']) {
      final field = tester.widget<TextField>(
        find.byWidgetPredicate(
          (widget) =>
              widget is TextField && widget.decoration?.labelText == label,
        ),
      );
      expect(field.decoration?.filled, isNot(true));
      expect(field.decoration?.fillColor, isNull);
    }

    semantics.dispose();
  });

  testWidgets('recipe builder uses the shared collapsed nutrition summary', (
    tester,
  ) async {
    await tester.pumpWidget(testApp(const MealCreatorScreen()));
    await tester.pump();

    await tester.tap(find.byTooltip('Add food manually'));
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
    expect(find.text('0 g'), findsNWidgets(4));
    expect(find.text('No data yet'), findsOneWidget);
  });
}
