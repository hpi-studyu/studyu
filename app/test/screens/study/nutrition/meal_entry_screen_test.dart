import 'dart:ui' show SemanticsAction;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/nutrition/food_entry_screen.dart';
import 'package:studyu_app/screens/study/nutrition/food_quantity_sheet.dart';
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

MealLog editableMeal({String? customMealLabel = 'Supper'}) => MealLog(
  id: 'editable-meal',
  mealType: MealType.other,
  customMealLabel: customMealLabel,
  mealContext: MealContext.home,
  timestamp: DateTime(2026, 7, 15, 20),
  timezone: 'UTC',
  isSkipped: false,
  foods: [testFood()],
);

Future<void> openMealEntry(
  WidgetTester tester,
  MealLog meal, {
  NutritionTask? task,
  ValueChanged<MealLog?>? onResult,
  ValueChanged<MealEntryResult?>? onEntryResult,
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
                  final result = await Navigator.of(context)
                      .push<MealEntryResult>(
                        MaterialPageRoute(
                          builder: (_) =>
                              MealEntryScreen(existingMeal: meal, task: task),
                        ),
                      );
                  onEntryResult?.call(result);
                  onResult?.call(
                    result is SavedMealEntryResult ? result.meal : null,
                  );
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

Future<void> selectMealType(
  WidgetTester tester,
  String label, {
  String? customLabel,
}) async {
  await tester.tap(find.text('Meal Type'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
  if (customLabel != null) {
    await tester.enterText(find.byType(TextField).last, customLabel);
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
  }
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

  testWidgets('new meal uses the requested initial meal type', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          locale: Locale('en'),
          home: MealEntryScreen(initialMealType: MealType.dinner),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Meal Type'), findsOneWidget);
    expect(find.text('Dinner'), findsWidgets);
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Dinner')),
      findsOneWidget,
    );
    expect(find.widgetWithText(TextButton, 'Save'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Save'), findsNothing);
    expect(find.text('Delete meal'), findsNothing);
  });

  testWidgets('new meal uses the requested custom meal label', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          locale: Locale('en'),
          home: MealEntryScreen(
            initialMealType: MealType.other,
            initialCustomMealLabel: 'Late bite',
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Meal Type'), findsOneWidget);
    expect(find.text('Late bite'), findsWidgets);
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Late bite'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('existing meal wins over requested initial values', (
    tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          locale: const Locale('en'),
          home: MealEntryScreen(
            existingMeal: editableMeal(),
            initialMealType: MealType.dinner,
            initialCustomMealLabel: 'Ignored',
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Meal Type'), findsOneWidget);
    expect(find.text('Supper'), findsWidgets);
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Supper')),
      findsOneWidget,
    );
    expect(find.text('Ignored'), findsNothing);
  });

  testWidgets('built-in meal type clears an existing custom label', (
    tester,
  ) async {
    MealEntryResult? result;
    await openMealEntry(
      tester,
      editableMeal(),
      onEntryResult: (value) => result = value,
    );

    await selectMealType(tester, 'Dinner');

    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Dinner')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Supper')),
      findsNothing,
    );

    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await tester.pumpAndSettle();

    expect(result, isA<SavedMealEntryResult>());
    final savedMeal = (result! as SavedMealEntryResult).meal;
    expect(savedMeal.mealType, MealType.dinner);
    expect(savedMeal.customMealLabel, isNull);
  });

  testWidgets('meal type sheet uses task-specific choices', (tester) async {
    MealEntryResult? result;
    final task = NutritionTask.withId()
      ..customMealTypes = ['Morning meal', 'Evening snack', 'Other'];
    await openMealEntry(
      tester,
      editableMeal(),
      task: task,
      onEntryResult: (value) => result = value,
    );

    await tester.tap(find.text('Meal Type'));
    await tester.pumpAndSettle();

    expect(find.text('Morning meal'), findsOneWidget);
    expect(find.text('Evening snack'), findsOneWidget);
    expect(find.text('Other'), findsOneWidget);
    expect(find.text('Breakfast'), findsNothing);

    await tester.tap(find.text('Evening snack'));
    await tester.pumpAndSettle();
    expect(find.text('Evening snack'), findsWidgets);

    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await tester.pumpAndSettle();

    final meal = (result! as SavedMealEntryResult).meal;
    expect(meal.mealType, MealType.other);
    expect(meal.customMealLabel, 'Evening snack');
  });

  testWidgets('custom meal choices represent an existing generic Other', (
    tester,
  ) async {
    final task = NutritionTask.withId()
      ..customMealTypes = ['Morning meal', 'Evening snack'];
    await openMealEntry(
      tester,
      editableMeal(customMealLabel: null),
      task: task,
    );

    await tester.tap(find.text('Meal Type'));
    await tester.pumpAndSettle();

    final otherTile = tester.widget<ListTile>(
      find.widgetWithText(ListTile, 'Other').last,
    );
    expect((otherTile.leading! as Icon).icon, Icons.radio_button_checked);
    expect(find.text('Breakfast'), findsNothing);
  });

  testWidgets('custom meal choices can save generic Other', (tester) async {
    MealEntryResult? result;
    final task = NutritionTask.withId()
      ..customMealTypes = ['Morning meal', 'Evening snack'];
    await openMealEntry(
      tester,
      editableMeal(customMealLabel: 'Morning meal'),
      task: task,
      onEntryResult: (value) => result = value,
    );

    await tester.tap(find.text('Meal Type'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Other').last);
    await tester.pumpAndSettle();
    expect(find.text('Other'), findsWidgets);

    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await tester.pumpAndSettle();

    final meal = (result! as SavedMealEntryResult).meal;
    expect(meal.mealType, MealType.other);
    expect(meal.customMealLabel, isEmpty);
  });

  testWidgets('meal details apply atomically and dismissal discards edits', (
    tester,
  ) async {
    MealEntryResult? result;
    await openMealEntry(
      tester,
      editableMeal(),
      onEntryResult: (value) => result = value,
    );

    await tester.ensureVisible(find.text('Meal details'));
    await tester.tap(find.text('Meal details'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byWidgetPredicate(
        (widget) =>
            widget is DropdownButtonFormField &&
            widget.decoration.labelText == 'Who were you with?',
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Family').last);
    await tester.pumpAndSettle();
    await tester.drag(find.byType(BottomSheet), const Offset(0, 600));
    await tester.pumpAndSettle();

    expect(find.text('Family'), findsNothing);
    expect(find.text('Home'), findsOneWidget);

    await tester.tap(find.text('Meal details'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byWidgetPredicate(
        (widget) =>
            widget is DropdownButtonFormField &&
            widget.decoration.labelText == 'Who were you with?',
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Family').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Family'), findsNothing);
    expect(find.text('Home'), findsOneWidget);

    await tester.tap(find.text('Meal details'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byWidgetPredicate(
        (widget) =>
            widget is DropdownButtonFormField &&
            widget.decoration.labelText == 'Who were you with?',
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Family').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(find.text('Home • Family'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await tester.pumpAndSettle();
    expect(
      (result! as SavedMealEntryResult).meal.companyContext,
      CompanyContext.family,
    );
  });

  testWidgets('meal details clear a hidden location description', (
    tester,
  ) async {
    MealEntryResult? result;
    await openMealEntry(
      tester,
      MealLog(
        id: 'location-meal',
        mealType: MealType.dinner,
        mealContext: MealContext.other,
        locationDescription: 'Park',
        timestamp: DateTime(2026, 7, 15, 20),
        timezone: 'UTC',
        isSkipped: false,
        foods: [testFood()],
      ),
      onEntryResult: (value) => result = value,
    );

    await tester.ensureVisible(find.text('Meal details'));
    await tester.tap(find.text('Meal details'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byWidgetPredicate(
        (widget) =>
            widget is DropdownButtonFormField &&
            widget.decoration.labelText == 'Where did you eat?',
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Meal details'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byWidgetPredicate(
        (widget) =>
            widget is DropdownButtonFormField &&
            widget.decoration.labelText == 'Where did you eat?',
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Other').last);
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      isEmpty,
    );
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await tester.pumpAndSettle();

    final meal = (result! as SavedMealEntryResult).meal;
    expect(meal.mealContext, MealContext.home);
    expect(meal.locationDescription, isNull);
  });

  testWidgets('skipped meal only asks for a reason and keeps save visible', (
    tester,
  ) async {
    await openMealEntry(tester, skippedMeal());

    expect(find.text('Reason for skipping'), findsOneWidget);
    expect(find.text('Meal Type'), findsNothing);
    expect(find.text('Meal context'), findsNothing);
    var reasonField = tester.widget<TextField>(find.byType(TextField));
    expect(reasonField.decoration?.errorText, isNull);

    final saveButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Save'),
    );
    expect(saveButton.onPressed, isNotNull);

    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await tester.pump();

    reasonField = tester.widget<TextField>(find.byType(TextField));
    expect(reasonField.decoration?.errorText, 'Enter a reason before saving.');

    await tester.enterText(find.byType(TextField), 'Not hungry');
    await tester.pump();

    reasonField = tester.widget<TextField>(find.byType(TextField));
    expect(reasonField.decoration?.errorText, isNull);
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
      expect(find.text('Food items'), findsOneWidget);
      expect(find.text('Meal Nutrition'), findsNothing);
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
        findsNothing,
      );
      final saveButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Save'),
      );
      expect(saveButton.onPressed, isNotNull);

      await tester.tap(find.widgetWithText(TextButton, 'Save'));
      await tester.pump();

      expect(result, isNull);
      expect(find.byType(MealEntryScreen), findsOneWidget);
      expect(
        find.descendant(
          of: emptyFoodState,
          matching: find.text('Add at least one food item before saving.'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Skipped this meal'));
      await tester.pump();

      expect(
        tester.widget<TextField>(find.byType(TextField)).decoration?.errorText,
        'Enter a reason before saving.',
      );

      await tester.enterText(find.byType(TextField), 'Not hungry');
      await tester.pump();

      expect(result, isNull);
      expect(find.byType(MealEntryScreen), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).decoration?.errorText,
        isNull,
      );
    },
  );

  testWidgets('food workspace appears before meal details', (tester) async {
    await openMealEntry(tester, editableMeal());

    expect(
      tester.getTopLeft(find.text('Food items')).dy,
      lessThan(tester.getTopLeft(find.text('Meal Type')).dy),
    );
  });

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

  testWidgets('opens Photo Recall in a sheet and preserves the meal draft', (
    tester,
  ) async {
    const channel = MethodChannel('com.fluttercandies/photo_manager');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          switch (call.method) {
            case 'getPermissionState':
              return PermissionState.authorized.index;
            case 'getAssetPathList':
              return <dynamic>[];
          }
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );

    MealEntryResult? result;
    await openMealEntry(
      tester,
      editableMeal(),
      onEntryResult: (value) => result = value,
    );
    await selectMealType(tester, 'Dinner');

    final semantics = tester.ensureSemantics();
    final photoRecallRow = find.ancestor(
      of: find.text('Photo Recall'),
      matching: find.byType(ListTile),
    );
    expect(photoRecallRow, findsOneWidget);
    expect(
      tester
          .getSemantics(photoRecallRow)
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isTrue,
    );
    semantics.dispose();

    await tester.tap(photoRecallRow);
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.text('No photos found'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(result, isA<SavedMealEntryResult>());
    expect((result! as SavedMealEntryResult).meal.mealType, MealType.dinner);
  });

  testWidgets('back offers save discard and continue actions', (tester) async {
    await openMealEntry(tester, skippedMeal());
    await tester.enterText(find.byType(TextField), 'Not hungry');
    await tester.pump();

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Leave this meal?'), findsOneWidget);
    expect(
      find.text('Save your changes, discard them, or continue editing.'),
      findsOneWidget,
    );
    expect(find.text('Save and leave'), findsOneWidget);
    expect(find.text('Discard changes'), findsOneWidget);
    expect(find.text('Continue editing'), findsOneWidget);

    await tester.tap(find.text('Continue editing'));
    await tester.pumpAndSettle();

    expect(find.byType(MealEntryScreen), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard changes'));
    await tester.pumpAndSettle();

    expect(find.byType(MealEntryScreen), findsNothing);
    expect(find.text('Open meal'), findsOneWidget);
  });

  testWidgets('save and leave returns the validated meal', (tester) async {
    MealLog? result;
    await openMealEntry(
      tester,
      skippedMeal(),
      onResult: (value) => result = value,
    );
    await tester.enterText(find.byType(TextField), 'Not hungry');
    await tester.pump();

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save and leave'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.skipReason, 'Not hungry');
    expect(find.byType(MealEntryScreen), findsNothing);
  });

  testWidgets('save and leave keeps an invalid meal open', (tester) async {
    await openMealEntry(tester, emptyMeal());
    await selectMealType(tester, 'Dinner');

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save and leave'));
    await tester.pumpAndSettle();

    expect(find.byType(MealEntryScreen), findsOneWidget);
    expect(
      find.text('Add at least one food item before saving.'),
      findsOneWidget,
    );
  });

  testWidgets('existing meal can return a typed deleted result', (
    tester,
  ) async {
    MealEntryResult? result;
    await openMealEntry(
      tester,
      editableMeal(),
      onEntryResult: (value) => result = value,
    );

    await tester.ensureVisible(find.text('Delete meal'));
    await tester.tap(find.text('Delete meal'));
    await tester.pumpAndSettle();

    expect(find.text('Delete this meal?'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(result, isA<DeletedMealEntryResult>());
    expect(find.byType(MealEntryScreen), findsNothing);
  });

  testWidgets('food editor hides search and preserves the meal draft', (
    tester,
  ) async {
    await openMealEntry(tester, editableMeal());

    await selectMealType(tester, 'Other', customLabel: 'Edited supper');

    await tester.ensureVisible(find.text('Apple'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apple'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(find.byType(FoodEntryScreen), findsOneWidget);
    expect(find.byTooltip('Search Food Database'), findsNothing);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.byType(MealEntryScreen), findsOneWidget);
    expect(find.text('Edited supper'), findsWidgets);
  });

  testWidgets('recipe builder return preserves and saves the meal draft', (
    tester,
  ) async {
    final original = editableMeal();
    MealLog? result;
    await openMealEntry(tester, original, onResult: (value) => result = value);

    await selectMealType(tester, 'Other', customLabel: 'Edited supper');

    final addFoodButton = find.widgetWithText(FilledButton, 'Add Food');
    await tester.ensureVisible(addFoodButton);
    await tester.tap(addFoodButton);
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.text('Add food to Edited supper'), findsOneWidget);

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    final recipeResult = navigator.push<FoodEntry>(RecipeBuilderScreen.route());
    await tester.pumpAndSettle();

    expect(find.byType(RecipeBuilderScreen), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(await recipeResult, isNull);
    expect(find.byType(RecipeBuilderScreen), findsNothing);

    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();

    expect(find.byType(MealEntryScreen), findsOneWidget);
    expect(find.text('Edited supper'), findsWidgets);
    expect(find.text('Apple'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.customMealLabel, 'Edited supper');
    expect(result!.foods, hasLength(1));
    expect(result!.foods.single.id, 'food');
    expect(result!.foods.single.name, 'Apple');
    expect(original.customMealLabel, 'Supper');
    expect(original.foods, hasLength(1));
  });

  testWidgets('template quantity return preserves and saves the meal draft', (
    tester,
  ) async {
    final prototype = FoodEntry.fromJson(testFood().toJson())
      ..id = 'saved-food-prototype'
      ..name = 'Saved Pear'
      ..originalValues = {
        'nested': {'value': 1},
      };
    prototype.nutrition.micros = {'vitaminC': 5};
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

    await selectMealType(tester, 'Other', customLabel: 'Edited supper');
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Add Food'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Add Food'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Saved Pear Template'));
    await tester.pumpAndSettle();

    expect(find.text('Add to Edited supper'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(FoodQuantitySheet),
        matching: find.byIcon(Icons.add),
      ),
    );
    await tester.pump();
    expect(find.text('104 kcal'), findsOneWidget);
    await tester.tap(find.text('Add to Edited supper'));
    await tester.pumpAndSettle();

    expect(find.text('Edited supper'), findsWidgets);
    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('Saved Pear'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.customMealLabel, 'Edited supper');
    expect(result!.foods, hasLength(2));
    expect(result!.foods.first.id, 'food');
    expect(result!.foods.first.name, 'Apple');
    expect(result!.foods.last.id, isNot(prototype.id));
    expect(result!.foods.last.name, 'Saved Pear');
    expect(result!.foods.last.amount, 2);
    expect(result!.foods.last.nutrition.energyKcal, 104);
    expect(result!.foods.last.nutrition.micros['vitaminC'], 10);
    expect(result!.foods.last.source, prototype.source);
    expect(result!.foods.last.templateId, 'saved-food-template');
    expect(result!.foods.last.originalValues, prototype.originalValues);
    expect(original.customMealLabel, 'Supper');
    expect(original.foods, hasLength(1));
  });

  testWidgets('saved meal adds cloned foods without replacing meal details', (
    tester,
  ) async {
    final pear = FoodEntry.fromJson(testFood().toJson())
      ..id = 'pear-prototype'
      ..name = 'Pear';
    final yogurt = FoodEntry.fromJson(testFood().toJson())
      ..id = 'yogurt-prototype'
      ..name = 'Yogurt';
    await TemplateStorageManager().saveMealTemplate(
      SavedMealTemplate(
        id: 'saved-meal-template',
        userId: 'anonymous',
        name: 'Afternoon Snack',
        mealType: MealType.snack,
        isPublic: false,
        createdAt: DateTime(2026, 7, 15),
        prototypes: [pear, yogurt],
      ),
    );
    final original = editableMeal();
    MealLog? result;
    await openMealEntry(tester, original, onResult: (value) => result = value);
    await selectMealType(tester, 'Other', customLabel: 'Edited supper');
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Add Food'));
    await tester.tap(find.widgetWithText(FilledButton, 'Add Food'));
    await tester.pumpAndSettle();

    expect(find.text('Manage saved items'), findsOneWidget);
    await tester.tap(find.text('Afternoon Snack'));
    await tester.pumpAndSettle();

    expect(find.text('Pear'), findsOneWidget);
    expect(find.text('Yogurt'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.mealType, MealType.other);
    expect(result!.customMealLabel, 'Edited supper');
    expect(result!.mealContext, original.mealContext);
    expect(result!.timestamp, original.timestamp);
    expect(result!.foods, hasLength(3));
    expect(result!.foods[1].id, isNot(pear.id));
    expect(result!.foods[2].id, isNot(yogurt.id));
    expect(result!.foods[1].templateId, 'saved-meal-template');
    expect(result!.foods[2].templateId, 'saved-meal-template');
    expect(original.foods, hasLength(1));
  });

  testWidgets('food actions use a sheet and duplicate with fresh identity', (
    tester,
  ) async {
    final original = editableMeal();
    MealLog? result;
    await openMealEntry(tester, original, onResult: (value) => result = value);

    expect(find.byType(PopupMenuButton<String>), findsNothing);
    await tester.tap(find.byTooltip('More options'));
    await tester.pumpAndSettle();

    expect(find.text('Adjust quantity'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Duplicate'), findsOneWidget);
    expect(find.text('Save as Template'), findsOneWidget);
    expect(find.text('Delete'), findsWidgets);
    await tester.tap(find.text('Duplicate'));
    await tester.pumpAndSettle();

    expect(find.text('Apple'), findsNWidgets(2));
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.foods, hasLength(2));
    expect(result!.foods.first.id, original.foods.first.id);
    expect(result!.foods.last.id, isNot(original.foods.first.id));
    expect(result!.foods.last.source, original.foods.first.source);
    expect(result!.foods.last.externalId, original.foods.first.externalId);
    expect(result!.foods.last.templateId, original.foods.first.templateId);
    expect(original.foods, hasLength(1));
  });

  testWidgets('canceling template or quantity selection adds no food', (
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
    await selectMealType(tester, 'Other', customLabel: 'Edited supper');
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Add Food'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Add Food'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();

    expect(find.text('Saved Pear'), findsNothing);
    expect(find.text('Edited supper'), findsWidgets);
    expect(find.text('Apple'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Add Food'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Saved Pear Template'));
    await tester.pumpAndSettle();
    expect(find.text('Add to Edited supper'), findsOneWidget);
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();

    expect(find.text('Saved Pear'), findsNothing);
    expect(find.text('Edited supper'), findsWidgets);
    expect(find.text('Apple'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.customMealLabel, 'Edited supper');
    expect(result!.foods, hasLength(1));
    expect(result!.foods.single.id, 'food');
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
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
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

    await tester.tap(find.widgetWithText(TextButton, 'Save'));
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
