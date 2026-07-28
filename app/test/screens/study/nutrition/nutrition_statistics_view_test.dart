import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_recall_records.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_statistics_view.dart';
import 'package:studyu_core/core.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('formats nutrition decimal values for the active locale', (
    tester,
  ) async {
    final subject = StudySubject('subject', 'study', 'user', [])
      ..startedAt = DateTime.utc(2026, 7, 14);
    final recall = DailyRecall(
      id: 'recall',
      date: DateTime.utc(2026, 7, 15),
      recallMode: RecallMode.realtimeRecord,
      meals: [
        MealLog(
          id: 'meal',
          mealType: MealType.breakfast,
          mealContext: MealContext.home,
          timezone: 'UTC',
          isSkipped: false,
          foods: [_food()],
        ),
      ],
      studyDaySnapshot: 1,
    );
    subject.progress.add(
      SubjectProgress(
        subjectId: subject.id,
        interventionId: 'intervention',
        taskId: 'task',
        resultType: 'DailyRecall',
        result: Result<DailyRecall>.app(
          type: 'DailyRecall',
          periodId: 'period',
          result: recall,
        ),
      )..completedAt = DateTime.utc(2026, 7, 15, 12),
    );

    await tester.pumpWidget(
      MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        locale: const Locale('de'),
        home: NutritionStatisticsView(subject: subject, taskId: 'task'),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('1,5 g'), findsOneWidget);
    expect(find.text('1.234 kcal'), findsOneWidget);
  });

  test('merges the active recall with the six latest history days', () {
    final activeRecall = _recall(studyDay: 8, energyKcal: 100);
    final cachedRecords = [
      for (var studyDay = 8; studyDay > 0; studyDay--)
        NutritionRecallRecord(
          recall: _recall(studyDay: studyDay, energyKcal: 1),
          taskId: 'task',
          periodId: 'period',
          interventionId: 'intervention',
          studyDaySnapshot: studyDay,
        ),
    ];

    List<NutritionStatisticsDay> days() => nutritionStatisticsDays(
      cachedRecords,
      activeRecall: activeRecall,
      activeStudyDay: 8,
      activePeriodId: 'period',
    );

    expect(days().map((day) => day.studyDaySnapshot), [8, 7, 6, 5, 4, 3, 2]);
    expect(days().first.nutrition.energyKcal, 100);

    activeRecall.meals.add(_meal(energyKcal: 50));
    expect(days().first.nutrition.energyKcal, 150);

    activeRecall.meals[0] = _meal(energyKcal: 200);
    expect(days().first.nutrition.energyKcal, 250);

    activeRecall.meals.removeLast();
    expect(days().first.nutrition.energyKcal, 200);
  });
}

DailyRecall _recall({required int studyDay, required double energyKcal}) =>
    DailyRecall(
      id: 'recall-$studyDay-$energyKcal',
      date: DateTime.utc(2026, 7, 15).add(Duration(days: studyDay)),
      recallMode: RecallMode.realtimeRecord,
      meals: [_meal(energyKcal: energyKcal)],
      studyDaySnapshot: studyDay,
    );

MealLog _meal({required double energyKcal}) => MealLog(
  id: 'meal-$energyKcal',
  mealType: MealType.breakfast,
  mealContext: MealContext.home,
  timezone: 'UTC',
  isSkipped: false,
  foods: [_food(energyKcal: energyKcal)],
);

FoodEntry _food({double energyKcal = 1234}) => FoodEntry(
  id: 'food',
  entryType: FoodEntryType.singleIngredient,
  name: 'Food',
  amount: 1,
  unit: 'serving',
  servingSizeGrams: 100,
  portionEstimationMethod: PortionEstimationMethod.standardUnit,
  portionState: PortionState.asServed,
  nutrition: NutritionProfile(
    energyKcal: energyKcal,
    protein: 1.5,
    carbs: 2.5,
    fat: 3.5,
    sugars: 0,
    fiber: 0,
    saturatedFat: 0,
    transFat: 0,
    cholesterol: 0,
    sodium: 0,
    waterContent: 0,
    micros: {},
  ),
  source: FoodSource.manual,
  confidenceScore: 1,
  createdAt: DateTime.utc(2026, 7, 15),
  originalValues: {},
);
