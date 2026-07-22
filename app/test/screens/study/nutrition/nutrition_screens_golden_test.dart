import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/nutrition/food_entry_screen.dart';
import 'package:studyu_app/screens/study/nutrition/meal_entry_screen.dart';
import 'package:studyu_app/screens/study/nutrition/recipe_builder_screen.dart';
import 'package:studyu_app/screens/study/tasks/observation/nutrition_task_widget.dart';
import 'package:studyu_core/core.dart';

const _goldenKey = Key('nutrition-golden');
const _sizes = {'mobile': Size(414, 844), 'wide': Size(1280, 800)};

Widget _goldenApp(Widget screen) => ChangeNotifierProvider(
  create: (_) => AppState(),
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    locale: const Locale('en'),
    theme: ThemeData(
      useMaterial3: true,
      platform: TargetPlatform.android,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff006a6a)),
      visualDensity: VisualDensity.standard,
    ),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: child!,
    ),
    home: RepaintBoundary(key: _goldenKey, child: screen),
  ),
);

Future<void> _expectGolden(
  WidgetTester tester, {
  required Size size,
  required Widget screen,
  required String name,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);

  await tester.pumpWidget(_goldenApp(screen));
  await tester.pumpAndSettle();

  await expectLater(
    find.byKey(_goldenKey),
    matchesGoldenFile('goldens/$name.png'),
  );
}

FoodEntry _food() => FoodEntry(
  id: 'golden-food',
  entryType: FoodEntryType.brandedProduct,
  name: 'Whole Grain Granola Bar',
  brandName: 'Example Foods',
  description: 'Oats, almonds, and dried fruit',
  amount: 1,
  unit: 'bar',
  servingSizeGrams: 42,
  portionReference: 'one bar',
  portionEstimationMethod: PortionEstimationMethod.standardUnit,
  portionState: PortionState.asServed,
  nutrition: NutritionProfile(
    energyKcal: 190,
    protein: 5,
    carbs: 28,
    fat: 7,
    sugars: 9,
    fiber: 4,
    saturatedFat: 1,
    transFat: 0,
    cholesterol: 0,
    sodium: 120,
    waterContent: 3,
    micros: const {'iron': 1.8},
  ),
  foodCode: 'golden-code',
  externalId: 'golden-external',
  source: FoodSource.openfoodfacts,
  confidenceScore: 1,
  createdAt: DateTime.utc(2026, 7, 15, 12),
  originalValues: const {},
);

MealLog _skippedMeal() => MealLog(
  id: 'golden-meal',
  mealType: MealType.lunch,
  mealContext: MealContext.home,
  timestamp: DateTime(2026, 7, 15, 12, 30),
  timezone: 'UTC',
  isSkipped: true,
  skipReason: 'Travel schedule',
  foods: const [],
);

NutritionTask _nutritionTask() => NutritionTask.withId()
  ..title = 'Nutrition Diary'
  ..instructions = 'Record everything you eat and drink today.'
  ..minimumMealsRequired = 2;

DailyRecall _dailyRecall() => DailyRecall(
  id: 'golden-recall',
  date: DateTime(2026, 7, 15),
  recallMode: RecallMode.realtimeRecord,
  entryStartedAt: DateTime(2026, 7, 15, 8),
  meals: [
    MealLog(
      id: 'golden-recorded-meal',
      mealType: MealType.lunch,
      mealContext: MealContext.home,
      timestamp: DateTime(2026, 7, 15, 12, 30),
      timezone: 'UTC',
      isSkipped: false,
      foods: [_food()],
    ),
  ],
);

CompletionPeriod _completionPeriod() => CompletionPeriod(
  id: 'golden-period',
  unlockTime: StudyUTimeOfDay(),
  lockTime: StudyUTimeOfDay(hour: 23),
);

void main() {
  for (final size in _sizes.entries) {
    testWidgets('meal entry ${size.key}', (tester) async {
      await _expectGolden(
        tester,
        size: size.value,
        screen: MealEntryScreen(existingMeal: _skippedMeal()),
        name: 'meal_entry_${size.key}',
      );
    });

    testWidgets('food details ${size.key}', (tester) async {
      await _expectGolden(
        tester,
        size: size.value,
        screen: FoodEntryScreen(existingFood: _food(), showSearchAction: false),
        name: 'food_details_${size.key}',
      );
    });

    if (size.key == 'wide') {
      testWidgets('recipe builder wide', (tester) async {
        await _expectGolden(
          tester,
          size: size.value,
          screen: const RecipeBuilderScreen(),
          name: 'recipe_builder_wide',
        );
      });
    }

    testWidgets('nutrition task ${size.key}', (tester) async {
      await _expectGolden(
        tester,
        size: size.value,
        screen: NutritionTaskWidget(
          existingRecall: _dailyRecall(),
          task: _nutritionTask(),
          completionPeriod: _completionPeriod(),
        ),
        name: 'nutrition_task_${size.key}',
      );
    });
  }
}
