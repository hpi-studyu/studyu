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
    expect(find.text('Macronutrients'), findsOneWidget);
    expect(find.text('Energy by macronutrient'), findsOneWidget);
    expect(find.text('Carbs 23%'), findsOneWidget);
    expect(find.text('Protein 37%'), findsOneWidget);
    expect(find.text('Fat 40%'), findsOneWidget);
    expect(
      tester
          .getSemantics(find.byType(NutritionMacroDistributionBar))
          .getSemanticsData()
          .label,
      contains('Carbohydrates 23%, Protein 37%, Fat 40%'),
    );
    expect(find.text('Detailed Nutrients'), findsOneWidget);
    expect(find.text('Fibre'), findsNothing);
    expect(find.byIcon(Icons.expand_more), findsOneWidget);
    final detailsSemantics = tester.getSemantics(
      find.bySemanticsLabel('Detailed Nutrients'),
    );
    expect(
      detailsSemantics.getSemanticsData().hasAction(SemanticsAction.tap),
      isTrue,
    );
    expect(find.text('Show'), findsNothing);
    expect(find.text('Hide'), findsNothing);
    expect(
      find.textContaining('Some nutrient values are unavailable for 1 item.'),
      findsOneWidget,
    );
    expect(find.text('—'), findsNothing);

    await tester.tap(find.text('Detailed Nutrients'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.expand_less), findsOneWidget);
    expect(find.text('—'), findsOneWidget);
    expect(find.text('0 g'), findsAtLeastNWidgets(1));

    semantics.dispose();
  });

  testWidgets('macro distribution selection exposes anchored detail', (
    tester,
  ) async {
    await tester.pumpWidget(
      testApp(
        const NutritionMacroDistributionBar(
          carbs: 30.7,
          protein: 50.4,
          fat: 23.9,
        ),
      ),
    );

    expect(find.text('Energy by macronutrient'), findsOneWidget);
    expect(find.text('Carbs 23%'), findsOneWidget);
    await tester.tap(find.text('Carbs 23%'));
    await tester.pumpAndSettle();

    expect(find.text('Carbohydrates: 23% · 123 kcal'), findsOneWidget);
  });

  testWidgets(
    'macro segments expose tap semantics and select matching detail',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        testApp(
          const NutritionMacroDistributionBar(
            carbs: 30.7,
            protein: 50.4,
            fat: 23.9,
          ),
        ),
      );

      final segment = find.bySemanticsLabel('Carbohydrates, 23%');
      expect(segment, findsOneWidget);
      expect(
        tester
            .getSemantics(segment)
            .getSemanticsData()
            .hasAction(SemanticsAction.tap),
        isTrue,
      );
      await tester.tap(segment);
      await tester.pumpAndSettle();

      expect(find.text('Carbohydrates: 23% · 123 kcal'), findsOneWidget);
      semantics.dispose();
    },
  );

  testWidgets('zero macro energy has no distribution chart', (tester) async {
    await tester.pumpWidget(
      testApp(
        const NutritionMacroDistributionBar(carbs: 0, protein: 0, fat: 0),
      ),
    );

    expect(find.text('Energy by macronutrient'), findsNothing);
    expect(find.textContaining('%'), findsNothing);
    expect(find.textContaining('kcal'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('positive macros with nonpositive energy show placeholder', (
    tester,
  ) async {
    final nutrition = NutritionProfile(
      energyKcal: 0,
      protein: 10,
      carbs: 20,
      fat: 5,
      sugars: 0,
      fiber: 0,
      saturatedFat: 0,
      transFat: 0,
      cholesterol: 0,
      sodium: 0,
      waterContent: 0,
      micros: const {},
    );
    await tester.pumpWidget(
      testApp(
        Scaffold(
          body: SingleChildScrollView(
            child: NutritionSummaryCard(nutrition: nutrition),
          ),
        ),
      ),
    );

    expect(find.text('—'), findsOneWidget);
    expect(find.text('0 kcal'), findsNothing);
    expect(find.text('Energy by macronutrient'), findsNothing);
  });

  testWidgets('German distribution wraps at narrow width', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: NutritionMacroDistributionBar(
              carbs: 30.7,
              protein: 50.4,
              fat: 23.9,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Energie nach Makronährstoffen'), findsOneWidget);
    expect(find.text('Kohlenhydrate 23%'), findsOneWidget);
    expect(tester.takeException(), isNull);
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
    expect(find.text('0 g'), findsNWidgets(3));
    expect(find.text('0%'), findsNothing);
    expect(find.text('No data yet'), findsNothing);
  });
}
