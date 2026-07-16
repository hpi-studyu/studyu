import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/study/nutrition/meal_entry_screen.dart';
import 'package:studyu_app/screens/study/nutrition/meal_entry_screen_helper.dart';
import 'package:studyu_core/core.dart';

FoodEntry testFood() => FoodEntry(
  id: 'food',
  entryType: FoodEntryType.singleIngredient,
  name: 'Apple',
  amount: 1,
  unit: 'piece',
  servingSizeGrams: 100,
  portionEstimationMethod: PortionEstimationMethod.householdMeasure,
  portionState: PortionState.raw,
  nutrition: NutritionProfile(
    energyKcal: 52,
    protein: 0.3,
    carbs: 14,
    fat: 0.2,
    sugars: 10,
    fiber: 2.4,
    saturatedFat: 0,
    transFat: 0,
    cholesterol: 0,
    sodium: 1,
    waterContent: 86,
    micros: {},
  ),
  source: FoodSource.manual,
  confidenceScore: 1,
  createdAt: DateTime(2026, 7, 15),
  originalValues: {
    'nested': {'value': 1},
  },
);

MealLog skippedMeal({String? reason}) => MealLog(
  id: 'meal',
  mealType: MealType.breakfast,
  customMealLabel: 'Early breakfast',
  mealContext: MealContext.home,
  locationDescription: 'Kitchen',
  timestamp: DateTime(2026, 7, 15, 8),
  timezone: 'UTC',
  isSkipped: true,
  skipReason: reason,
  companyContext: CompanyContext.family,
  distractionContext: DistractionContext.phone,
  templateId: 'template',
  foods: [testFood()],
);

Future<void> openMealEntry(
  WidgetTester tester,
  MealLog meal, {
  ValueChanged<MealLog?>? onResult,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      locale: const Locale('en'),
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: FilledButton(
              onPressed: () async {
                final result = await Navigator.of(context).push<MealLog>(
                  MaterialPageRoute(
                    builder: (_) => MealEntryScreen(existingMeal: meal),
                  ),
                );
                onResult?.call(result);
              },
              child: const Text('Open meal'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open meal'));
  await tester.pumpAndSettle();
}

void main() {
  test('meal clone does not share nested food metadata', () {
    final original = skippedMeal();
    final clone = cloneMealLog(original);

    (clone.foods.single.originalValues['nested']
            as Map<String, dynamic>)['value'] =
        2;

    expect(
      (original.foods.single.originalValues['nested']
          as Map<String, dynamic>)['value'],
      1,
    );
  });

  testWidgets('skipped meal only asks for a reason and keeps save visible', (
    tester,
  ) async {
    await openMealEntry(tester, skippedMeal());

    expect(find.text('Reason for skipping'), findsOneWidget);
    expect(find.text('Meal Type'), findsNothing);
    expect(find.text('Meal context'), findsNothing);

    var saveButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Save'),
    );
    expect(saveButton.onPressed, isNull);

    await tester.enterText(find.byType(TextField), 'Not hungry');
    await tester.pump();

    saveButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Save'),
    );
    expect(saveButton.onPressed, isNotNull);
  });

  testWidgets('back asks before discarding changed meal', (tester) async {
    await openMealEntry(tester, skippedMeal());
    await tester.enterText(find.byType(TextField), 'Not hungry');
    await tester.pump();

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Discard meal changes?'), findsOneWidget);
    expect(
      find.text('Your changes to this meal will be lost.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(MealEntryScreen), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();

    expect(find.byType(MealEntryScreen), findsNothing);
    expect(find.text('Open meal'), findsOneWidget);
  });

  testWidgets('saving a skipped meal removes contradictory details', (
    tester,
  ) async {
    MealLog? result;
    final original = skippedMeal(reason: 'Not hungry');
    await openMealEntry(tester, original, onResult: (value) => result = value);

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.isSkipped, isTrue);
    expect(result!.customMealLabel, isNull);
    expect(result!.locationDescription, isNull);
    expect(result!.companyContext, isNull);
    expect(result!.distractionContext, isNull);
    expect(result!.templateId, isNull);
    expect(result!.foods, isEmpty);
    expect(original.foods, hasLength(1));
    expect(original.locationDescription, 'Kitchen');
  });
}
