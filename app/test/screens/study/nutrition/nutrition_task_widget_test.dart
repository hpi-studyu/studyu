import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/tasks/observation/nutrition_task_widget.dart';
import 'package:studyu_app/util/template_storage_manager.dart';
import 'package:studyu_core/core.dart';

Widget nutritionTaskApp(NutritionTask task, {DailyRecall? existingRecall}) =>
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        locale: const Locale('en'),
        home: NutritionTaskWidget(
          existingRecall: existingRecall,
          task: task,
          completionPeriod: CompletionPeriod(
            id: 'period',
            unlockTime: StudyUTimeOfDay(),
            lockTime: StudyUTimeOfDay(hour: 23),
          ),
        ),
      ),
    );

NutritionTask nutritionTask({
  String? instructions,
  int? minimumMeals,
  List<String>? customMealTypes,
}) => NutritionTask.withId()
  ..title = 'Nutrition'
  ..instructions = instructions
  ..minimumMealsRequired = minimumMeals
  ..customMealTypes = customMealTypes;

NutritionProfile nutrition(double energyKcal) => NutritionProfile(
  energyKcal: energyKcal,
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
  micros: {},
);

FoodEntry food(String id, String name, double energyKcal) => FoodEntry(
  id: id,
  entryType: FoodEntryType.singleIngredient,
  name: name,
  amount: 1,
  unit: 'serving',
  servingSizeGrams: 100,
  portionEstimationMethod: PortionEstimationMethod.standardUnit,
  portionState: PortionState.asServed,
  nutrition: nutrition(energyKcal),
  source: FoodSource.manual,
  confidenceScore: 1,
  createdAt: DateTime(2026, 7, 15),
  originalValues: {},
);

MealLog meal(
  String id,
  MealType type, {
  String? label,
  List<FoodEntry> foods = const [],
  bool isSkipped = false,
}) => MealLog(
  id: id,
  mealType: type,
  customMealLabel: label,
  mealContext: MealContext.home,
  timestamp: DateTime(2026, 7, 15, 12),
  timezone: 'UTC',
  isSkipped: isSkipped,
  skipReason: isSkipped ? 'Not hungry' : null,
  foods: foods,
);

DailyRecall recall(List<MealLog> meals) => DailyRecall(
  id: 'recall',
  date: DateTime(2026, 7, 15),
  recallMode: RecallMode.realtimeRecord,
  entryStartedAt: DateTime(2026, 7, 15, 8),
  meals: meals,
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows the recall date as non-interactive header text', (
    tester,
  ) async {
    await tester.pumpWidget(
      nutritionTaskApp(
        nutritionTask(instructions: '   '),
        existingRecall: recall([]),
      ),
    );
    await tester.pump();

    final expectedDate = MaterialLocalizations.of(
      tester.element(find.byType(NutritionTaskWidget)),
    ).formatMediumDate(DateTime(2026, 7, 15));
    final date = find.text(expectedDate);

    expect(find.text('Instructions'), findsNothing);
    expect(date, findsOneWidget);
    expect(
      find.ancestor(of: date, matching: find.byType(InkWell)),
      findsNothing,
    );
    expect(
      find.ancestor(of: date, matching: find.byType(IconButton)),
      findsNothing,
    );
  });

  testWidgets('empty overview uses tappable predefined meal rows', (
    tester,
  ) async {
    await tester.pumpWidget(nutritionTaskApp(nutritionTask()));
    await tester.pump();

    expect(find.text('No meals recorded yet'), findsNothing);
    expect(find.text('Breakfast'), findsOneWidget);
    expect(find.text('Lunch'), findsOneWidget);
    expect(find.text('Dinner'), findsOneWidget);
    expect(find.text('Snacks'), findsOneWidget);
    expect(find.text('Other meals'), findsOneWidget);
    expect(find.text('No foods added'), findsNWidgets(5));
    expect(find.text('Log food'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('empty-meal-category-breakfast')),
    );
    await tester.pumpAndSettle();

    final breakfastChip = tester.widget<FilterChip>(
      find.widgetWithText(FilterChip, 'Breakfast'),
    );
    expect(breakfastChip.selected, isTrue);
  });

  testWidgets('custom meal rows preselect and persist their configured label', (
    tester,
  ) async {
    final prototype = food('saved-food', 'Saved apple', 52);
    await TemplateStorageManager().saveFoodTemplate(
      SavedFoodTemplate(
        id: 'saved-food-template',
        userId: 'anonymous',
        name: 'Saved apple template',
        isPublic: false,
        createdAt: DateTime(2026, 7, 15),
        prototype: prototype,
      ),
    );

    await tester.pumpWidget(
      nutritionTaskApp(
        nutritionTask(customMealTypes: ['Morning meal', 'Late meal']),
      ),
    );
    await tester.pump();

    expect(find.text('Breakfast'), findsNothing);
    expect(find.text('Morning meal'), findsOneWidget);
    expect(find.text('Late meal'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('empty-meal-category-custom-Morning meal')),
    );
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<FilterChip>(find.widgetWithText(FilterChip, 'Morning meal'))
          .selected,
      isTrue,
    );

    await tester.ensureVisible(find.text('Add Food'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Food'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Saved apple template'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await tester.pumpAndSettle();

    expect(find.text('Morning meal'), findsNWidgets(2));
    expect(find.text('Saved apple'), findsOneWidget);
  });

  testWidgets('custom tasks keep unmatched legacy meals under Other meals', (
    tester,
  ) async {
    await tester.pumpWidget(
      nutritionTaskApp(
        nutritionTask(customMealTypes: ['Morning meal']),
        existingRecall: recall([
          meal(
            'configured',
            MealType.other,
            label: 'Morning meal',
            foods: [food('apple', 'Apple', 52)],
          ),
          meal(
            'unmatched',
            MealType.other,
            label: 'Late bite',
            foods: [food('toast', 'Toast', 80)],
          ),
          meal(
            'legacy',
            MealType.breakfast,
            foods: [food('eggs', 'Eggs', 140)],
          ),
        ]),
      ),
    );
    await tester.pump();

    expect(find.text('Morning meal'), findsNWidgets(2));
    expect(find.text('Other meals'), findsOneWidget);
    expect(find.text('Late bite'), findsOneWidget);
    expect(find.text('Breakfast'), findsOneWidget);
    expect(find.text('Lunch'), findsNothing);
    expect(find.text('Toast'), findsOneWidget);
    expect(find.text('Eggs'), findsOneWidget);
  });

  testWidgets('keeps multiple and custom meals separate with previews', (
    tester,
  ) async {
    await tester.pumpWidget(
      nutritionTaskApp(
        nutritionTask(),
        existingRecall: recall([
          meal('snack-1', MealType.snack, foods: [food('apple', 'Apple', 52)]),
          meal(
            'snack-2',
            MealType.snack,
            foods: [food('yogurt', 'Yogurt', 90)],
          ),
          meal('brunch', MealType.brunch, foods: [food('eggs', 'Eggs', 140)]),
          meal(
            'custom',
            MealType.other,
            label: 'Late bite',
            foods: [food('toast', 'Toast', 80)],
          ),
          meal('skipped', MealType.breakfast, isSkipped: true),
        ]),
      ),
    );
    await tester.pump();

    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('Yogurt'), findsOneWidget);
    expect(find.text('Brunch'), findsOneWidget);
    expect(find.text('Late bite'), findsOneWidget);
    expect(find.text('Not hungry'), findsOneWidget);
    expect(find.textContaining('52 kcal'), findsOneWidget);
    expect(find.textContaining('90 kcal'), findsOneWidget);
  });

  testWidgets('deleted editor result removes only the selected meal', (
    tester,
  ) async {
    await tester.pumpWidget(
      nutritionTaskApp(
        nutritionTask(),
        existingRecall: recall([
          meal(
            'breakfast',
            MealType.breakfast,
            foods: [food('apple', 'Apple', 52)],
          ),
          meal('lunch', MealType.lunch, foods: [food('yogurt', 'Yogurt', 90)]),
        ]),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Apple'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Delete meal'));
    await tester.tap(find.text('Delete meal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.byType(NutritionTaskWidget), findsOneWidget);
    expect(find.text('Apple'), findsNothing);
    expect(find.text('Yogurt'), findsOneWidget);
  });

  testWidgets('shows nutrition instructions without a collapsed section', (
    tester,
  ) async {
    await tester.pumpWidget(
      nutritionTaskApp(nutritionTask(instructions: 'Record every meal.')),
    );
    await tester.pump();

    expect(find.text('Instructions'), findsOneWidget);
    expect(find.text('Record every meal.'), findsOneWidget);
    expect(find.byType(ExpansionTile), findsNothing);
  });

  testWidgets(
    'shows the minimum meal requirement without custom instructions',
    (tester) async {
      await tester.pumpWidget(nutritionTaskApp(nutritionTask(minimumMeals: 2)));
      await tester.pump();

      expect(find.text('Instructions'), findsOneWidget);
      expect(find.text('Please record at least 2 meal(s)'), findsOneWidget);
    },
  );
}
