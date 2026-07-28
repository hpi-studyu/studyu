import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/tasks/observation/nutrition_task_widget.dart';
import 'package:studyu_app/util/study_subject_extension.dart';
import 'package:studyu_core/core.dart';

Widget nutritionTaskApp(
  NutritionTask task, {
  DailyRecall? existingRecall,
  Locale locale = const Locale('en'),
  HistoricalNutritionEditingContext? historicalContext,
}) => ChangeNotifierProvider(
  create: (_) => AppState(),
  child: MaterialApp(
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    locale: locale,
    home: NutritionTaskWidget(
      existingRecall: existingRecall,
      task: task,
      persistenceTarget: historicalContext?.target,
      historicalContext: historicalContext,
      completionPeriod: CompletionPeriod(
        id: 'period',
        unlockTime: StudyUTimeOfDay(),
        lockTime: StudyUTimeOfDay(hour: 23),
      ),
    ),
  ),
);

class _NutritionLauncher extends StatefulWidget {
  const _NutritionLauncher({
    required this.task,
    required this.onResult,
    this.existingRecall,
  });

  final NutritionTask task;
  final DailyRecall? existingRecall;
  final ValueChanged<DailyRecall?> onResult;

  @override
  State<_NutritionLauncher> createState() => _NutritionLauncherState();
}

class _NutritionLauncherState extends State<_NutritionLauncher> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final result = await Navigator.of(context).push<DailyRecall>(
        NutritionTaskWidget.route(
          existingRecall: widget.existingRecall,
          task: widget.task,
          completionPeriod: CompletionPeriod(
            id: 'period',
            unlockTime: StudyUTimeOfDay(),
            lockTime: StudyUTimeOfDay(hour: 23),
          ),
        ),
      );
      widget.onResult(result);
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

NutritionTask nutritionTask({
  String? instructions,
  int? minimumMeals,
  List<String>? customMealTypes,
  bool requireDailyCompletionConfirmation = true,
}) => NutritionTask.withId()
  ..title = 'Nutrition'
  ..instructions = instructions
  ..minimumMealsRequired = minimumMeals
  ..customMealTypes = customMealTypes
  ..requireDailyCompletionConfirmation = requireDailyCompletionConfirmation;

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
  foodId: '$id-definition',
  foodVersionId: '$id-version',
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
  MealOccurrenceTimePrecision timePrecision =
      MealOccurrenceTimePrecision.approximate,
}) => MealLog(
  id: id,
  mealType: type,
  customMealLabel: label,
  mealContext: MealContext.home,
  timestamp: DateTime(2026, 7, 15, 12),
  timePrecision: timePrecision,
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

  testWidgets('historical mode shows context and hides workspace navigation', (
    tester,
  ) async {
    final date = DateTime(2026, 7, 15);
    final target = NutritionRecallPersistenceTarget(
      taskId: 'task',
      periodId: 'period',
      interventionId: 'intervention',
      completedAt: DateTime.utc(2026, 7, 15, 12),
      studyDaySnapshot: 1,
    );

    await tester.pumpWidget(
      nutritionTaskApp(
        nutritionTask(),
        existingRecall: recall([
          meal('meal', MealType.breakfast, foods: [food('food', 'Apple', 100)]),
        ]),
        historicalContext: HistoricalNutritionEditingContext(
          target: target,
          recallDate: date,
        ),
      ),
    );
    await tester.pump();

    expect(find.textContaining('Editing'), findsNWidgets(2));
    expect(
      find.text('Entry changes apply only to this study day'),
      findsOneWidget,
    );
    expect(find.text('Statistics'), findsNothing);
    expect(find.text('My items'), findsNothing);
    expect(find.byIcon(Icons.history_outlined), findsNothing);
    expect(find.byIcon(Icons.help_outline), findsNothing);

    await tester.tap(find.text('Apple'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.bookmark_add_outlined), findsNothing);
    expect(find.text('My items'), findsNothing);
  });

  testWidgets('never renders manual completion controls', (tester) async {
    await tester.pumpWidget(
      nutritionTaskApp(
        nutritionTask(requireDailyCompletionConfirmation: false),
        existingRecall: recall([meal('meal', MealType.breakfast)]),
      ),
    );
    await tester.pump();

    expect(find.text('Finish today’s nutrition log'), findsNothing);
    expect(
      find.text('This submits your current nutrition log for today.'),
      findsNothing,
    );
  });

  testWidgets(
    'statistics destination uses statistics help and no history action',
    (tester) async {
      await tester.pumpWidget(
        nutritionTaskApp(
          nutritionTask(),
          existingRecall: recall([meal('meal', MealType.breakfast)]),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Statistics'));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Statistics'),
        ),
        findsOneWidget,
      );
      expect(find.byTooltip('History'), findsNothing);

      await tester.tap(find.byTooltip('Help'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Averages include only completed study days'),
        findsOneWidget,
      );
    },
  );

  testWidgets('task-mode exit returns no completion result', (tester) async {
    var didReturn = false;
    DailyRecall? result;
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          locale: const Locale('en'),
          home: _NutritionLauncher(
            task: nutritionTask(),
            existingRecall: recall([meal('meal', MealType.breakfast)]),
            onResult: (value) {
              didReturn = true;
              result = value;
            },
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(didReturn, isTrue);
    expect(result, isNull);
  });

  testWidgets('warns before leaving without the minimum meals', (tester) async {
    var didReturn = false;
    DailyRecall? result;
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          locale: const Locale('en'),
          home: _NutritionLauncher(
            task: nutritionTask(minimumMeals: 1),
            existingRecall: recall([]),
            onResult: (value) {
              didReturn = true;
              result = value;
            },
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Minimum meals not reached'), findsOneWidget);
    await tester.tap(find.text('Leave anyway'));
    await tester.pumpAndSettle();

    expect(didReturn, isTrue);
    expect(result, isNull);
  });

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

  testWidgets('empty overview uses one log-meal action', (tester) async {
    await tester.pumpWidget(nutritionTaskApp(nutritionTask()));
    await tester.pump();

    expect(find.text('No meals recorded yet'), findsOneWidget);
    expect(find.text('Breakfast'), findsNothing);
    expect(find.text('Log meal'), findsOneWidget);

    await tester.tap(find.text('Log meal'));
    await tester.pumpAndSettle();

    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Log meal')),
      findsOneWidget,
    );
  });

  testWidgets('German nutrition timeline uses participant translations', (
    tester,
  ) async {
    await tester.pumpWidget(
      nutritionTaskApp(nutritionTask(), locale: const Locale('de')),
    );
    await tester.pump();

    expect(find.text('Mahlzeiten'), findsOneWidget);
    expect(find.text('Mahlzeit erfassen'), findsOneWidget);
    expect(find.text('Meals'), findsNothing);

    await tester.tap(find.text('Mahlzeit erfassen'));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Mahlzeit erfassen'),
      ),
      findsOneWidget,
    );
    expect(find.text('Lunch'), findsNothing);
  });

  testWidgets('configured custom labels remain available in the editor', (
    tester,
  ) async {
    await tester.pumpWidget(
      nutritionTaskApp(
        nutritionTask(customMealTypes: ['Morning meal', 'Late meal']),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Log meal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Meal label'));
    await tester.pumpAndSettle();

    expect(find.text('Morning meal'), findsOneWidget);
    expect(find.text('Late meal'), findsOneWidget);
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

    expect(find.textContaining('Morning meal'), findsOneWidget);
    expect(find.textContaining('Other'), findsNothing);
    expect(find.textContaining('Late bite'), findsOneWidget);
    expect(find.textContaining('Breakfast'), findsOneWidget);
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
    expect(find.textContaining('Brunch'), findsOneWidget);
    expect(find.textContaining('Late bite'), findsOneWidget);
    expect(find.textContaining('Not hungry'), findsOneWidget);
    expect(find.textContaining('52 kcal'), findsOneWidget);
    expect(find.textContaining('90 kcal'), findsOneWidget);
  });

  testWidgets('timeline deletion asks for confirmation', (tester) async {
    await tester.pumpWidget(
      nutritionTaskApp(
        nutritionTask(),
        existingRecall: recall([
          meal(
            'breakfast',
            MealType.breakfast,
            foods: [food('apple', 'Apple', 52)],
          ),
        ]),
      ),
    );
    await tester.pump();

    await tester.tap(find.byTooltip('More options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Delete this meal?'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Apple'), findsOneWidget);

    await tester.tap(find.byTooltip('More options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Apple'), findsNothing);
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

  testWidgets('groups unknown-time entries at the end', (tester) async {
    await tester.pumpWidget(
      nutritionTaskApp(
        nutritionTask(),
        existingRecall: recall([
          meal(
            'unknown',
            MealType.other,
            timePrecision: MealOccurrenceTimePrecision.unknown,
            foods: [food('tea', 'Tea', 5)],
          ),
          meal(
            'early',
            MealType.breakfast,
            foods: [food('cereal', 'Cereal', 200)],
          ),
        ]),
      ),
    );
    await tester.pump();

    expect(find.textContaining('Time not remembered'), findsNWidgets(2));
    expect(find.text('Tea'), findsOneWidget);
    expect(find.text('Cereal'), findsOneWidget);
    final cerealY = tester.getTopLeft(find.text('Cereal')).dy;
    final teaY = tester.getTopLeft(find.text('Tea')).dy;
    expect(cerealY, lessThan(teaY));
  });

  testWidgets('timestamp does not make unknown precision chronological', (
    tester,
  ) async {
    await tester.pumpWidget(
      nutritionTaskApp(
        nutritionTask(),
        existingRecall: recall([
          meal(
            'unknown',
            MealType.other,
            timePrecision: MealOccurrenceTimePrecision.unknown,
            foods: [food('tea', 'Tea', 5)],
          )..timestamp = DateTime(2026, 7, 15, 6),
          meal('later', MealType.dinner, foods: [food('bread', 'Bread', 100)]),
        ]),
      ),
    );
    await tester.pump();

    expect(
      tester.getTopLeft(find.text('Bread')).dy,
      lessThan(tester.getTopLeft(find.text('Tea')).dy),
    );
  });

  testWidgets('adjacent category entries share one icon header', (
    tester,
  ) async {
    await tester.pumpWidget(
      nutritionTaskApp(
        nutritionTask(),
        existingRecall: recall([
          meal(
            'first',
            MealType.breakfast,
            foods: [food('cereal', 'Cereal', 200)],
          )..timestamp = DateTime(2026, 7, 15, 8),
          meal(
            'second',
            MealType.breakfast,
            foods: [food('toast', 'Toast', 150)],
          )..timestamp = DateTime(2026, 7, 15, 9),
        ]),
      ),
    );
    await tester.pump();

    expect(find.text('Breakfast'), findsOneWidget);
    expect(find.text('Cereal'), findsOneWidget);
    expect(find.text('Toast'), findsOneWidget);
    expect(find.textContaining('Breakfast •'), findsNothing);
  });

  testWidgets('interleaved categories stay chronological', (tester) async {
    await tester.pumpWidget(
      nutritionTaskApp(
        nutritionTask(),
        existingRecall: recall([
          meal(
            'first',
            MealType.breakfast,
            foods: [food('cereal', 'Cereal', 200)],
          )..timestamp = DateTime(2026, 7, 15, 8),
          meal('lunch', MealType.lunch, foods: [food('pasta', 'Pasta', 500)])
            ..timestamp = DateTime(2026, 7, 15, 12),
          meal(
            'second',
            MealType.breakfast,
            foods: [food('toast', 'Toast', 150)],
          )..timestamp = DateTime(2026, 7, 15, 13),
        ]),
      ),
    );
    await tester.pump();

    final breakfastHeaders = find.text('Breakfast');
    expect(breakfastHeaders, findsNWidgets(2));
    expect(
      tester.getTopLeft(breakfastHeaders.at(0)).dy,
      lessThan(tester.getTopLeft(find.text('Lunch')).dy),
    );
    expect(
      tester.getTopLeft(find.text('Lunch')).dy,
      lessThan(tester.getTopLeft(breakfastHeaders.at(1)).dy),
    );
  });

  testWidgets('historical Other and skipped labels remain visible', (
    tester,
  ) async {
    await tester.pumpWidget(
      nutritionTaskApp(
        nutritionTask(),
        existingRecall: recall([
          meal('other', MealType.other, foods: [food('tea', 'Tea', 5)]),
          meal(
            'skipped',
            MealType.other,
            label: 'Early breakfast',
            isSkipped: true,
          ),
        ]),
      ),
    );
    await tester.pump();

    expect(find.textContaining('Other'), findsOneWidget);
    expect(find.textContaining('Early breakfast'), findsOneWidget);
  });
}
