import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_recall_records.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_statistics_view.dart';
import 'package:studyu_core/core.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows localized averages for completed study days', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 1600);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final semantics = tester.ensureSemantics();
    final today = DateUtils.dateOnly(DateTime.now());
    final subject = StudySubject('subject', 'study', 'user', [])
      ..startedAt = today.subtract(const Duration(days: 1));
    final recall = _recall(
      date: today,
      studyDay: 1,
      energyKcal: 1234,
      completed: true,
    );
    subject.progress.add(_progress(recall));

    await tester.pumpWidget(
      MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        locale: const Locale('de'),
        home: NutritionStatisticsView(subject: subject, taskId: 'task'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tagesdurchschnitt'), findsOneWidget);
    expect(find.text('1.234 kcal'), findsWidgets);
    expect(find.text('1,5 g'), findsOneWidget);
    final energyCard = find.ancestor(
      of: find.text('Energie pro Studientag'),
      matching: find.byType(Card),
    );
    expect(
      find.descendant(of: energyCard, matching: find.text('kcal')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: energyCard, matching: find.text('Heute')),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(RegExp('Heute bisher, 1\\.234 kcal')),
      findsOneWidget,
    );

    final nutrientTitle = find.text('Nährstoffverlauf').first;
    final nutrientCard = find
        .ancestor(of: nutrientTitle, matching: find.byType(Card))
        .first;
    expect(
      find.descendant(of: nutrientCard, matching: find.text('g')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: nutrientCard, matching: find.text('Heute')),
      findsOneWidget,
    );
    for (final label in ['0', '0,05', '0,1', '0,15', '0,2']) {
      expect(
        find.descendant(of: nutrientCard, matching: find.text(label)),
        findsOneWidget,
      );
    }
    for (var offset = 6; offset > 0; offset--) {
      final label = DateFormat.E('de').format(addCalendarDays(today, -offset));
      expect(
        find.descendant(of: nutrientCard, matching: find.text(label)),
        findsOneWidget,
      );
    }
    semantics.dispose();

    await tester.ensureVisible(find.text('Letzte 30 Tage'));
    await tester.tap(find.text('Letzte 30 Tage'));
    await tester.pumpAndSettle();

    expect(find.textContaining('1 von 30 Tagen erfasst'), findsOneWidget);
    final thirtyDayEnergyCard = find
        .ancestor(
          of: find.text('Energie pro Studientag'),
          matching: find.byType(Card),
        )
        .first;
    for (final index in [0, 5, 10, 15, 20, 25]) {
      final label = DateFormat(
        'd MMM',
        'de',
      ).format(addCalendarDays(today, index - 29));
      expect(
        find.descendant(of: thirtyDayEnergyCard, matching: find.text(label)),
        findsOneWidget,
      );
    }
    expect(
      find.descendant(of: thirtyDayEnergyCard, matching: find.text('Heute')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  test('excludes incomplete today from averages but keeps it in charts', () {
    final today = DateUtils.dateOnly(DateTime.now());
    final records = [
      _record(
        date: today.subtract(const Duration(days: 2)),
        studyDay: 1,
        energyKcal: 100,
      ),
      _record(
        date: today.subtract(const Duration(days: 1)),
        studyDay: 2,
        energyKcal: 200,
      ),
      _record(date: today, studyDay: 3, energyKcal: 250),
    ];
    final activeRecall = _recall(date: today, studyDay: 3, energyKcal: 300);

    final period = nutritionStatisticsPeriod(
      nutritionStatisticsDays(
        records,
        activeRecall: activeRecall,
        activeStudyDay: 3,
        activePeriodId: 'period',
      ),
      endDate: today,
      dayCount: 7,
    );

    expect(period.recordedCount, 2);
    expect(period.average((value) => value.energyKcal), 150);
    expect(period.days.last.isRecorded, isFalse);
    expect(period.days.last.hasChartData, isTrue);
    expect(period.days.first.hasChartData, isFalse);
  });

  test('adds calendar days without carrying an elapsed-time offset', () {
    final nextDay = addCalendarDays(DateTime(2026, 3, 29), 1);

    expect(nextDay, DateTime(2026, 3, 30));
    expect(nextDay.hour, 0);
  });

  test('compares equal-length periods using recorded days only', () {
    final today = DateUtils.dateOnly(DateTime.now());
    final statisticsDays = nutritionStatisticsDays([
      _record(
        date: today.subtract(const Duration(days: 1)),
        studyDay: 14,
        energyKcal: 200,
      ),
      _record(
        date: today.subtract(const Duration(days: 2)),
        studyDay: 13,
        energyKcal: 100,
      ),
      _record(
        date: today.subtract(const Duration(days: 8)),
        studyDay: 7,
        energyKcal: 50,
      ),
      _record(
        date: today.subtract(const Duration(days: 9)),
        studyDay: 6,
        energyKcal: 50,
      ),
    ]);
    final current = nutritionStatisticsPeriod(
      statisticsDays,
      endDate: today,
      dayCount: 7,
    );
    final previous = nutritionStatisticsPeriod(
      statisticsDays,
      endDate: today.subtract(const Duration(days: 7)),
      dayCount: 7,
    );

    expect(current.recordedCount, 2);
    expect(previous.recordedCount, 2);
    expect(
      current.average((value) => value.energyKcal)! -
          previous.average((value) => value.energyKcal)!,
      100,
    );
  });
}

NutritionRecallRecord _record({
  required DateTime date,
  required int studyDay,
  required double energyKcal,
}) {
  final recall = _recall(
    date: date,
    studyDay: studyDay,
    energyKcal: energyKcal,
  );
  return NutritionRecallRecord(
    recall: recall,
    taskId: 'task',
    periodId: 'period',
    interventionId: 'intervention',
    studyDaySnapshot: studyDay,
    progress: _progress(recall),
  );
}

SubjectProgress _progress(DailyRecall recall) => SubjectProgress(
  subjectId: 'subject',
  interventionId: 'intervention',
  taskId: 'task',
  resultType: 'DailyRecall',
  result: Result<DailyRecall>.app(
    type: 'DailyRecall',
    periodId: 'period',
    result: recall,
  ),
)..completedAt = recall.date.add(const Duration(hours: 12));

DailyRecall _recall({
  required DateTime date,
  required int studyDay,
  required double energyKcal,
  bool completed = false,
}) => DailyRecall(
  id: 'recall-$studyDay-$energyKcal',
  date: date,
  recallMode: RecallMode.realtimeRecord,
  entryCompletedAt: completed ? date.add(const Duration(hours: 12)) : null,
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

FoodEntry _food({required double energyKcal}) => FoodEntry(
  id: 'food-$energyKcal',
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
    carbs: 0.2,
    fat: 3.5,
    sugars: 0,
    fiber: 4.5,
    saturatedFat: 0,
    transFat: 0,
    cholesterol: 0,
    sodium: 0,
    waterContent: 0,
    micros: {},
  ),
  source: FoodSource.manual,
  confidenceScore: 1,
  createdAt: DateTime.now(),
  originalValues: {},
);
