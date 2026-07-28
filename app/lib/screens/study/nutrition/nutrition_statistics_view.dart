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

enum _NutritionStatisticsMode { day, recentDays }

class _NutritionStatisticsViewState extends State<NutritionStatisticsView> {
  late Future<List<NutritionRecallRecord>> _records;
  late int _selectedStudyDay;
  var _mode = _NutritionStatisticsMode.day;

  @override
  void initState() {
    super.initState();
    _records = _loadRecords();
    _selectedStudyDay = _todayStudyDay;
  }

  int get _todayStudyDay {
    final subject = widget.subject;
    if (subject?.startedAt == null) return widget.activeStudyDay ?? 0;
    final day = subject!.getDayOfStudyFor(DateTime.now());
    return day < 0 ? 0 : day;
  }

  bool get _canNavigateDays => widget.subject?.startedAt != null;

  DateTime get _selectedDate {
    final start = widget.subject?.startedAt?.toLocal();
    if (start == null) {
      final activeRecall = widget.activeRecall;
      if (activeRecall != null && widget.activeStudyDay == _selectedStudyDay) {
        return activeRecall.date;
      }
      return DateUtils.dateOnly(DateTime.now());
    }
    return DateTime(start.year, start.month, start.day + _selectedStudyDay);
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: SizedBox(
            width: double.infinity,
            child: SegmentedButton<_NutritionStatisticsMode>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: _NutritionStatisticsMode.day,
                  label: Text(l10n.day),
                ),
                ButtonSegment(
                  value: _NutritionStatisticsMode.recentDays,
                  label: Text(l10n.nutrition_recent_days),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (selection) =>
                  setState(() => _mode = selection.first),
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<NutritionRecallRecord>>(
            future: _records,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final records = snapshot.data!;
              return switch (_mode) {
                _NutritionStatisticsMode.day => _buildDay(context, records),
                _NutritionStatisticsMode.recentDays => _buildRecentDays(
                  context,
                  records,
                ),
              };
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDay(BuildContext context, List<NutritionRecallRecord> records) {
    final l10n = AppLocalizations.of(context)!;
    final day = nutritionStatisticsDayForStudyDay(
      records,
      studyDay: _selectedStudyDay,
      subject: widget.subject,
      activeRecall: widget.activeRecall,
      activeStudyDay: widget.activeStudyDay,
      activePeriodId: widget.activePeriodId,
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              tooltip: l10n.back,
              onPressed: _canNavigateDays && _selectedStudyDay > 0
                  ? () => setState(() => _selectedStudyDay--)
                  : null,
            ),
            Expanded(
              child: Text(
                MaterialLocalizations.of(
                  context,
                ).formatMediumDate(_selectedDate),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              tooltip: l10n.next,
              onPressed: _canNavigateDays && _selectedStudyDay < _todayStudyDay
                  ? () => setState(() => _selectedStudyDay++)
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (day == null)
          Padding(
            padding: const EdgeInsets.only(top: 32),
            child: Center(child: Text(l10n.nutrition_statistics_empty)),
          )
        else
          DailyNutritionSummaryCard(
            key: ValueKey(day.studyDaySnapshot),
            dailyRecall: day.dailyRecall,
          ),
      ],
    );
  }

  Widget _buildRecentDays(
    BuildContext context,
    List<NutritionRecallRecord> records,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final days = nutritionStatisticsDays(
      records,
      subject: widget.subject,
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
          child: InkWell(
            onTap: () => setState(() {
              _selectedStudyDay = day.studyDaySnapshot;
              _mode = _NutritionStatisticsMode.day;
            }),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                MaterialLocalizations.of(
                                  context,
                                ).formatMediumDate(day.date),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            if (day.studyDaySnapshot == _todayStudyDay) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  l10n.today,
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _value(
                    l10n.nutrition_calories,
                    _calories(context, nutrition.energyKcal),
                  ),
                  _value(l10n.protein, _grams(context, nutrition.protein)),
                  _value(l10n.carbohydrates, _grams(context, nutrition.carbs)),
                  _value(l10n.fat, _grams(context, nutrition.fat)),
                ],
              ),
            ),
          ),
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
  final DailyRecall dailyRecall;

  const NutritionStatisticsDay({
    required this.studyDaySnapshot,
    required this.date,
    required this.nutrition,
    required this.dailyRecall,
  });
}

List<NutritionStatisticsDay> nutritionStatisticsDays(
  List<NutritionRecallRecord> records, {
  StudySubject? subject,
  DailyRecall? activeRecall,
  int? activeStudyDay,
  String? activePeriodId,
}) => _nutritionStatisticsDays(
  records,
  subject: subject,
  activeRecall: activeRecall,
  activeStudyDay: activeStudyDay,
  activePeriodId: activePeriodId,
).take(7).toList();

NutritionStatisticsDay? nutritionStatisticsDayForStudyDay(
  List<NutritionRecallRecord> records, {
  required int studyDay,
  StudySubject? subject,
  DailyRecall? activeRecall,
  int? activeStudyDay,
  String? activePeriodId,
}) {
  for (final day in _nutritionStatisticsDays(
    records,
    subject: subject,
    activeRecall: activeRecall,
    activeStudyDay: activeStudyDay,
    activePeriodId: activePeriodId,
  )) {
    if (day.studyDaySnapshot == studyDay) return day;
  }
  return null;
}

List<NutritionStatisticsDay> _nutritionStatisticsDays(
  List<NutritionRecallRecord> records, {
  StudySubject? subject,
  DailyRecall? activeRecall,
  int? activeStudyDay,
  String? activePeriodId,
}) {
  final mergedRecords = [...records];
  final activeDay = subject?.startedAt != null && activeRecall != null
      ? subject!.getDayOfStudyFor(activeRecall.date)
      : activeStudyDay ?? activeRecall?.studyDaySnapshot;
  if (activeRecall != null && activeDay != null) {
    mergedRecords.removeWhere((record) {
      final matchesPeriod =
          activePeriodId == null || record.periodId == activePeriodId;
      final matchesDay =
          record.studyDaySnapshot == activeDay ||
          DateUtils.isSameDay(record.recall.date, activeRecall.date);
      return matchesPeriod && matchesDay;
    });
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
    final studyDay = subject?.startedAt == null
        ? record.studyDaySnapshot
        : subject!.getDayOfStudyFor(record.recall.date);
    byDay.putIfAbsent(studyDay, () => []).add(record);
  }
  final days =
      byDay.entries.map((entry) {
        final recordsForDay = entry.value;
        final firstRecall = recordsForDay.first.recall;
        return NutritionStatisticsDay(
          studyDaySnapshot: entry.key,
          date: firstRecall.date,
          nutrition: sumNutritionFoods([
            for (final record in recordsForDay)
              for (final meal in record.recall.meals)
                if (!meal.isSkipped) ...meal.foods,
          ]),
          dailyRecall: DailyRecall(
            id: 'nutrition-statistics-${entry.key}',
            date: firstRecall.date,
            recallMode: firstRecall.recallMode,
            meals: [for (final record in recordsForDay) ...record.recall.meals],
            studyDaySnapshot: entry.key,
          ),
        );
      }).toList()..sort(
        (left, right) =>
            right.studyDaySnapshot.compareTo(left.studyDaySnapshot),
      );
  return days;
}
