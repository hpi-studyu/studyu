import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/study/nutrition/food_quantity_sheet.dart';
import 'package:studyu_core/core.dart';

FoodEntry apple() => FoodEntry(
  id: 'apple-id',
  entryType: FoodEntryType.singleIngredient,
  name: 'Apple',
  amount: 1,
  unit: 'medium',
  servingSizeGrams: 182,
  portionReference: 'Medium apple, 182 g',
  portionEstimationMethod: PortionEstimationMethod.standardUnit,
  portionState: PortionState.asServed,
  nutrition: NutritionProfile(
    energyKcal: 95,
    protein: 0.5,
    carbs: 25,
    fat: 0.3,
    sugars: 19,
    fiber: 4.4,
    saturatedFat: 0.1,
    transFat: 0,
    cholesterol: 0,
    sodium: 2,
    waterContent: 156,
    micros: {'vitaminC': 8.4},
  ),
  source: FoodSource.usda,
  confidenceScore: 1,
  createdAt: DateTime.utc(2026, 7, 15),
  originalValues: const {'source': 'fixture'},
);

Future<void> pumpSheet(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
  FoodEntry? food,
  FoodQuantityAction action = FoodQuantityAction.existingMeal,
  double? initialAmount,
  ValueChanged<FoodEntry?>? onResult,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      locale: locale,
      home: Builder(
        builder: (context) => Scaffold(
          body: FilledButton(
            onPressed: () async {
              final result = await FoodQuantitySheet.show(
                context,
                food: food ?? apple(),
                mealLabel: 'Snack',
                action: action,
                initialAmount: initialAmount,
              );
              onResult?.call(result);
            },
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('scales nutrition and returns an independent food', (
    tester,
  ) async {
    FoodEntry? result;
    await pumpSheet(tester, onResult: (value) => result = value);

    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('Medium apple, 182 g'), findsOneWidget);
    expect(find.text('95 kcal'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('190 kcal'), findsOneWidget);
    await tester.tap(find.text('Add to Snack'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.amount, 2);
    expect(result!.servingSizeGrams, 182);
    expect(result!.nutrition.energyKcal, 190);
    expect(result!.nutrition.protein, 1);
    expect(result!.nutrition.micros['vitaminC'], 16.8);
  });

  testWidgets('shows the current selection total', (tester) async {
    await pumpSheet(
      tester,
      action: FoodQuantityAction.updateSelection,
      initialAmount: 2,
    );

    expect(find.text('Per serving: 95 kcal'), findsOneWidget);
    expect(find.text('Selection total: 190 kcal'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('Selection total: 285 kcal'), findsOneWidget);
    expect(find.text('Update selection'), findsOneWidget);
  });

  testWidgets('invalid direct amounts disable adding', (tester) async {
    await pumpSheet(tester);

    await tester.enterText(find.byType(TextField), '0');
    await tester.pump();

    expect(find.text('Enter an amount greater than zero'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Add to Snack'),
          )
          .onPressed,
      isNull,
    );
  });

  testWidgets('invalid source amounts cannot be added', (tester) async {
    await pumpSheet(tester, food: apple()..amount = double.nan);

    expect(find.text('Enter an amount greater than zero'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Add to Snack'),
          )
          .onPressed,
      isNull,
    );
  });

  testWidgets('dismissal returns no food and German action is localized', (
    tester,
  ) async {
    FoodEntry? result = apple();
    await pumpSheet(
      tester,
      locale: const Locale('de'),
      onResult: (value) => result = value,
    );

    expect(find.text('Zu Snack hinzufügen'), findsOneWidget);
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    expect(result, isNull);
  });
}
