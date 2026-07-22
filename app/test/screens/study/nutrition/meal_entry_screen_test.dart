import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/nutrition/food_entry_screen.dart';
import 'package:studyu_app/screens/study/nutrition/meal_entry_screen.dart';
import 'package:studyu_app/screens/study/nutrition/meal_entry_screen_helper.dart';
import 'package:studyu_app/screens/study/nutrition/recipe_builder_screen.dart';
import 'package:studyu_app/util/template_storage_manager.dart';
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

MealLog emptyMeal() => MealLog(
  id: 'empty-meal',
  mealType: MealType.other,
  customMealLabel: 'Supper',
  mealContext: MealContext.home,
  timestamp: DateTime(2026, 7, 15, 20),
  timezone: 'UTC',
  isSkipped: false,
  foods: [],
);

MealLog editableMeal() => MealLog(
  id: 'editable-meal',
  mealType: MealType.other,
  customMealLabel: 'Supper',
  mealContext: MealContext.home,
  timestamp: DateTime(2026, 7, 15, 20),
  timezone: 'UTC',
  isSkipped: false,
  foods: [testFood()],
);

Future<void> openMealEntry(
  WidgetTester tester,
  MealLog meal, {
  ValueChanged<MealLog?>? onResult,
}) async {
  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
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
    ),
  );
  await tester.tap(find.text('Open meal'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

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
    var reasonField = tester.widget<TextField>(find.byType(TextField));
    expect(reasonField.decoration?.errorText, 'Enter a reason before saving.');

    var saveButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Save'),
    );
    expect(saveButton.onPressed, isNull);

    await tester.enterText(find.byType(TextField), 'Not hungry');
    await tester.pump();

    reasonField = tester.widget<TextField>(find.byType(TextField));
    expect(reasonField.decoration?.errorText, isNull);
    saveButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Save'),
    );
    expect(saveButton.onPressed, isNotNull);
  });

  testWidgets(
    'empty meal keeps validation beside food and does not auto-save',
    (tester) async {
      MealLog? result;
      await openMealEntry(
        tester,
        emptyMeal(),
        onResult: (value) => result = value,
      );

      final emptyFoodState = find.ancestor(
        of: find.text('Tap to add food'),
        matching: find.byType(InkWell),
      );
      expect(emptyFoodState, findsOneWidget);
      expect(tester.widget<InkWell>(emptyFoodState).onTap, isNotNull);
      expect(
        find.ancestor(
          of: find.text('Tap to add food'),
          matching: find.byType(Card),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: emptyFoodState,
          matching: find.text('Add at least one food item before saving.'),
        ),
        findsOneWidget,
      );
      var saveButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Save'),
      );
      expect(saveButton.onPressed, isNull);

      await tester.tap(find.text('Skipped this meal'));
      await tester.pump();

      expect(result, isNull);
      expect(find.byType(MealEntryScreen), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).decoration?.errorText,
        'Enter a reason before saving.',
      );
      saveButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Save'),
      );
      expect(saveButton.onPressed, isNull);

      await tester.enterText(find.byType(TextField), 'Not hungry');
      await tester.pump();

      expect(result, isNull);
      expect(find.byType(MealEntryScreen), findsOneWidget);
      saveButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Save'),
      );
      expect(saveButton.onPressed, isNotNull);
    },
  );

  testWidgets('meal fields cards and chips use native theme defaults', (
    tester,
  ) async {
    await openMealEntry(tester, editableMeal());

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            (widget.decoration?.filled == true ||
                widget.decoration?.fillColor != null),
      ),
      findsNothing,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is DropdownButtonFormField &&
            (widget.decoration.filled == true ||
                widget.decoration.fillColor != null),
      ),
      findsNothing,
    );

    for (final chip in tester.widgetList<FilterChip>(find.byType(FilterChip))) {
      expect(chip.backgroundColor, isNull);
      expect(chip.selectedColor, isNull);
      expect(chip.checkmarkColor, isNull);
    }

    for (final label in ['Meal Type', 'Time', 'Apple', 'Photo Recall']) {
      final card = tester.widget<Card>(
        find.ancestor(of: find.text(label), matching: find.byType(Card)).first,
      );
      expect(card.color, isNull);
    }
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

  testWidgets('food editor hides search and preserves the meal draft', (
    tester,
  ) async {
    await openMealEntry(tester, editableMeal());

    final customLabelField = find
        .ancestor(
          of: find.text('Custom Meal Label'),
          matching: find.byType(TextField),
        )
        .first;
    await tester.enterText(customLabelField, 'Edited supper');
    await tester.pump();

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -250),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apple'));
    await tester.pumpAndSettle();

    expect(find.byType(FoodEntryScreen), findsOneWidget);
    expect(find.byTooltip('Search Food Database'), findsNothing);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.byType(MealEntryScreen), findsOneWidget);
    expect(find.text('Edited supper'), findsOneWidget);
  });

  testWidgets('recipe builder return preserves and saves the meal draft', (
    tester,
  ) async {
    final original = editableMeal();
    MealLog? result;
    await openMealEntry(tester, original, onResult: (value) => result = value);

    final customLabelField = find
        .ancestor(
          of: find.text('Custom Meal Label'),
          matching: find.byType(TextField),
        )
        .first;
    await tester.enterText(customLabelField, 'Edited supper');
    await tester.pump();

    final addFoodButton = find.widgetWithText(FilledButton, 'Add Food');
    await tester.ensureVisible(addFoodButton);
    await tester.tap(addFoodButton);
    await tester.pumpAndSettle();

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    final recipeResult = navigator.push<FoodEntry>(RecipeBuilderScreen.route());
    await tester.pumpAndSettle();

    expect(find.byType(RecipeBuilderScreen), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(await recipeResult, isNull);
    expect(find.byType(RecipeBuilderScreen), findsNothing);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.byType(MealEntryScreen), findsOneWidget);
    expect(find.text('Edited supper'), findsOneWidget);
    expect(find.text('Apple'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.customMealLabel, 'Edited supper');
    expect(result!.foods, hasLength(1));
    expect(result!.foods.single.id, 'food');
    expect(result!.foods.single.name, 'Apple');
    expect(original.customMealLabel, 'Supper');
    expect(original.foods, hasLength(1));
  });

  testWidgets('template return preserves and saves the meal draft', (
    tester,
  ) async {
    final prototype = FoodEntry.fromJson(testFood().toJson())
      ..id = 'saved-food-prototype'
      ..name = 'Saved Pear';
    await TemplateStorageManager().saveFoodTemplate(
      SavedFoodTemplate(
        id: 'saved-food-template',
        userId: 'anonymous',
        name: 'Saved Pear Template',
        isPublic: false,
        createdAt: DateTime(2026, 7, 15),
        prototype: prototype,
      ),
    );
    final original = editableMeal();
    MealLog? result;
    await openMealEntry(tester, original, onResult: (value) => result = value);

    final customLabelField = find
        .ancestor(
          of: find.text('Custom Meal Label'),
          matching: find.byType(TextField),
        )
        .first;
    await tester.enterText(customLabelField, 'Edited supper');
    await tester.pump();
    await tester.ensureVisible(find.byTooltip('From Template'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('From Template'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Saved Pear Template'));
    await tester.pumpAndSettle();

    expect(find.text('Edited supper'), findsOneWidget);
    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('Saved Pear'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.customMealLabel, 'Edited supper');
    expect(result!.foods, hasLength(2));
    expect(result!.foods.first.id, 'food');
    expect(result!.foods.first.name, 'Apple');
    expect(result!.foods.last.id, isNot(prototype.id));
    expect(result!.foods.last.name, 'Saved Pear');
    expect(result!.foods.last.templateId, 'saved-food-template');
    expect(original.customMealLabel, 'Supper');
    expect(original.foods, hasLength(1));
  });

  testWidgets('switching a skipped meal back clears the skip reason', (
    tester,
  ) async {
    MealLog? result;
    await openMealEntry(
      tester,
      skippedMeal(reason: 'Not hungry'),
      onResult: (value) => result = value,
    );

    await tester.tap(find.text('Skipped this meal'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.isSkipped, isFalse);
    expect(result!.skipReason, isNull);
    expect(result!.foods, hasLength(1));
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
