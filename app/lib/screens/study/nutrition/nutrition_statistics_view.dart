import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_recall_records.dart';
import 'package:studyu_app/widgets/nutrition_summary_card.dart';
import 'package:studyu_core/core.dart';

class NutritionStatisticsView extends StatefulWidget {
  final StudySubject? subject;
  final String? taskId;
  final DailyRecall? activeRecall;
  final int? activeStudyDay;
  final String? activePeriodId;

  const NutritionStatisticsView({
    this.subject,
    this.taskId,
    this.activeRecall,
    this.activeStudyDay,
    this.activePeriodId,
    super.key,
  });

  @override
  State<NutritionStatisticsView> createState() =>
      _NutritionStatisticsViewState();
}

class _NutritionStatisticsViewState extends State<NutritionStatisticsView> {
  late Future<List<NutritionRecallRecord>> _records;

  @override
  void initState() {
    super.initState();
    _records = _loadRecords();
  }

  Future<List<NutritionRecallRecord>> _loadRecords() {
    final subject = widget.subject;
    final taskId = widget.taskId;
    if (subject == null || taskId == null) return Future.value([]);
    return loadNutritionRecallRecords(subject: subject, taskId: taskId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FutureBuilder<List<NutritionRecallRecord>>(
      future: _records,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final days = nutritionStatisticsDays(
          snapshot.data!,
          activeRecall: widget.activeRecall,
          activeStudyDay: widget.activeStudyDay,
          activePeriodId: widget.activePeriodId,
        );
        if (days.isEmpty) {
          return Center(child: Text(l10n.nutrition_statistics_empty));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: days.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final day = days[index];
            final nutrition = day.nutrition;
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      MaterialLocalizations.of(
                        context,
                      ).formatMediumDate(day.date),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _value(
                      l10n.nutrition_calories,
                      _calories(context, nutrition.energyKcal),
                    ),
                    _value(l10n.protein, _grams(context, nutrition.protein)),
                    _value(
                      l10n.carbohydrates,
                      _grams(context, nutrition.carbs),
                    ),
                    _value(l10n.fat, _grams(context, nutrition.fat)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _value(String label, String value) => Row(
    children: [
      Expanded(child: Text(label)),
      Text(value),
    ],
  );

  String _calories(BuildContext context, double value) =>
      '${_numberFormat(context, maximumFractionDigits: 0).format(value.round())} kcal';

  String _grams(BuildContext context, double value) =>
      '${_numberFormat(context, maximumFractionDigits: 1).format(value)} g';

  NumberFormat _numberFormat(
    BuildContext context, {
    required int maximumFractionDigits,
  }) =>
      NumberFormat.decimalPattern(Localizations.localeOf(context).toString())
        ..maximumFractionDigits = maximumFractionDigits;
}

class NutritionStatisticsDay {
  final int studyDaySnapshot;
  final DateTime date;
  final NutritionProfile nutrition;

  const NutritionStatisticsDay({
    required this.studyDaySnapshot,
    required this.date,
    required this.nutrition,
  });
}

List<NutritionStatisticsDay> nutritionStatisticsDays(
  List<NutritionRecallRecord> records, {
  DailyRecall? activeRecall,
  int? activeStudyDay,
  String? activePeriodId,
}) {
  final mergedRecords = [...records];
  final activeDay = activeStudyDay ?? activeRecall?.studyDaySnapshot;
  if (activeRecall != null && activeDay != null) {
    mergedRecords.removeWhere(
      (record) =>
          record.studyDaySnapshot == activeDay &&
          (activePeriodId == null || record.periodId == activePeriodId),
    );
    mergedRecords.add(
      NutritionRecallRecord(
        recall: activeRecall,
        taskId: '',
        periodId: activePeriodId,
        interventionId: '',
        studyDaySnapshot: activeDay,
      ),
    );
  }

  final byDay = <int, List<NutritionRecallRecord>>{};
  for (final record in mergedRecords) {
    byDay.putIfAbsent(record.studyDaySnapshot, () => []).add(record);
  }
  final days =
      byDay.entries.map((entry) {
        final recordsForDay = entry.value;
        return NutritionStatisticsDay(
          studyDaySnapshot: entry.key,
          date: recordsForDay.first.recall.date,
          nutrition: sumNutritionFoods([
            for (final record in recordsForDay)
              for (final meal in record.recall.meals)
                if (!meal.isSkipped) ...meal.foods,
          ]),
        );
      }).toList()..sort(
        (left, right) =>
            right.studyDaySnapshot.compareTo(left.studyDaySnapshot),
      );
  return days.take(7).toList();
}
