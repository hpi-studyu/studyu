import 'dart:async';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final Future<void> Function(NutritionRecallRecord record)? onOpenRecall;

  const NutritionStatisticsView({
    this.subject,
    this.taskId,
    this.activeRecall,
    this.activeStudyDay,
    this.activePeriodId,
    this.onOpenRecall,
    super.key,
  });

  @override
  State<NutritionStatisticsView> createState() =>
      _NutritionStatisticsViewState();
}

enum _StatisticsPeriod {
  recent7(7),
  recent30(30);

  final int days;

  const _StatisticsPeriod(this.days);
}

enum _Nutrient { carbs, protein, fat, fiber }

class _NutritionStatisticsViewState extends State<NutritionStatisticsView> {
  late Future<List<NutritionRecallRecord>> _records;
  _StatisticsPeriod _selectedPeriod = _StatisticsPeriod.recent7;
  _Nutrient _selectedNutrient = _Nutrient.carbs;
  int? _focusedEnergyDay;

  @override
  void initState() {
    super.initState();
    _records = _loadRecords();
  }

  @override
  void didUpdateWidget(covariant NutritionStatisticsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.subject != widget.subject ||
        oldWidget.taskId != widget.taskId) {
      _records = _loadRecords();
    }
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
        final now = DateTime.now();
        final statisticsDays = nutritionStatisticsDays(
          snapshot.data!,
          activeRecall: widget.activeRecall,
          activeStudyDay: widget.activeStudyDay,
          activePeriodId: widget.activePeriodId,
          today: now,
        );
        final current = nutritionStatisticsPeriod(
          statisticsDays,
          endDate: now,
          dayCount: _selectedPeriod.days,
          today: now,
        );
        final previous = nutritionStatisticsPeriod(
          statisticsDays,
          endDate: addCalendarDays(
            DateUtils.dateOnly(now),
            -_selectedPeriod.days,
          ),
          dayCount: _selectedPeriod.days,
          today: now,
        );
        final hasData = current.days.any((day) => day.hasChartData);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<_StatisticsPeriod>(
              segments: [
                ButtonSegment(
                  value: _StatisticsPeriod.recent7,
                  label: Text(l10n.nutrition_recent_7_days),
                ),
                ButtonSegment(
                  value: _StatisticsPeriod.recent30,
                  label: Text(l10n.nutrition_recent_30_days),
                ),
              ],
              selected: {_selectedPeriod},
              showSelectedIcon: false,
              onSelectionChanged: (selection) =>
                  setState(() => _selectedPeriod = selection.single),
            ),
            const SizedBox(height: 12),
            Text(
              '${_periodLabel(context, current.startDate, current.endDate)} · '
              '${l10n.nutrition_days_recorded(current.recordedCount, current.days.length)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            if (!hasData)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Center(child: Text(l10n.nutrition_statistics_empty)),
              )
            else ...[
              _overviewCard(context, current),
              const SizedBox(height: 12),
              _energyCard(context, current),
              const SizedBox(height: 12),
              _nutrientCard(context, current),
              const SizedBox(height: 12),
              _comparisonCard(context, current, previous),
            ],
          ],
        );
      },
    );
  }

  Widget _overviewCard(
    BuildContext context,
    NutritionStatisticsPeriod current,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final averageEnergy = current.average((nutrition) => nutrition.energyKcal);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.nutrition_daily_average,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text(
              _calories(context, averageEnergy),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            _value(
              l10n.carbohydrates,
              _grams(context, current.average((value) => value.carbs)),
            ),
            _value(
              l10n.protein,
              _grams(context, current.average((value) => value.protein)),
            ),
            _value(
              l10n.fat,
              _grams(context, current.average((value) => value.fat)),
            ),
            _value(
              l10n.fibre,
              _grams(context, current.average((value) => value.fiber)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _energyCard(BuildContext context, NutritionStatisticsPeriod current) {
    final l10n = AppLocalizations.of(context)!;
    final average = current.average((nutrition) => nutrition.energyKcal);
    final values = [
      for (final day in current.days)
        if (day.hasChartData) day.data!.nutrition.energyKcal,
    ];
    final maxY = _chartMax(values);
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.nutrition_energy_by_study_day,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Tooltip(
                  message: l10n.nutrition_statistics_help_message,
                  child: const Icon(Icons.info_outline, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(l10n.nutrition_average_value(_calories(context, average))),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: _energyChart(context, current, average, maxY),
            ),
            const SizedBox(height: 8),
            Text(l10n.nutrition_tap_bar_hint, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _energyChart(
    BuildContext context,
    NutritionStatisticsPeriod current,
    double? average,
    double maxY,
  ) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        Positioned.fill(
          child: ExcludeSemantics(
            child: BarChart(
              BarChartData(
                minY: 0,
                maxY: maxY,
                alignment: BarChartAlignment.spaceAround,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                ),
                titlesData: _titlesData(context, current),
                extraLinesData: ExtraLinesData(
                  horizontalLines: average == null
                      ? []
                      : [
                          HorizontalLine(
                            y: average,
                            color: theme.colorScheme.outline,
                            strokeWidth: 1,
                            dashArray: [4, 4],
                          ),
                        ],
                ),
                barGroups: [
                  for (var index = 0; index < current.days.length; index++)
                    BarChartGroupData(
                      x: index,
                      barRods: current.days[index].hasChartData
                          ? [
                              BarChartRodData(
                                toY: current
                                    .days[index]
                                    .data!
                                    .nutrition
                                    .energyKcal,
                                width: current.days.length == 7 ? 18 : 6,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4),
                                ),
                                color: current.days[index].isToday
                                    ? theme.colorScheme.tertiary
                                    : theme.colorScheme.primary,
                                borderSide: current.days[index].isToday
                                    ? BorderSide(
                                        color: theme.colorScheme.onSurface,
                                        width: 2,
                                      )
                                    : BorderSide.none,
                              ),
                            ]
                          : [],
                    ),
                ],
                barTouchData: BarTouchData(
                  touchCallback: (event, response) {
                    if (event is! FlTapUpEvent || response?.spot == null) {
                      return;
                    }
                    final day =
                        current.days[response!.spot!.touchedBarGroupIndex];
                    if (!day.isToday && day.data?.record != null) {
                      unawaited(_openDay(day));
                    }
                  },
                  touchTooltipData: BarTouchTooltipData(
                    fitInsideHorizontally: true,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final day = current.days[group.x];
                      return BarTooltipItem(
                        '${_tooltipDate(context, day)} · ${_calories(context, rod.toY)}',
                        TextStyle(color: theme.colorScheme.onInverseSurface),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          bottom: 28,
          child: Row(
            children: [
              for (var index = 0; index < current.days.length; index++)
                Expanded(
                  child: _accessibleEnergyDay(
                    context,
                    current.days[index],
                    index,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _accessibleEnergyDay(
    BuildContext context,
    NutritionStatisticsPeriodDay day,
    int index,
  ) {
    final canOpen =
        !day.isToday && day.data?.record != null && widget.onOpenRecall != null;
    return Focus(
      key: ValueKey(day.date),
      canRequestFocus: canOpen,
      onFocusChange: (focused) =>
          setState(() => _focusedEnergyDay = focused ? index : null),
      onKeyEvent: (node, event) {
        if (canOpen &&
            event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.space)) {
          unawaited(_openDay(day));
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Semantics(
        container: true,
        label: _accessibleDayLabel(
          context,
          day,
          day.hasChartData
              ? _calories(context, day.data!.nutrition.energyKcal)
              : null,
        ),
        hint: canOpen
            ? AppLocalizations.of(context)!.nutrition_view_day_hint
            : null,
        button: canOpen,
        onTap: canOpen ? () => unawaited(_openDay(day)) : null,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: _focusedEnergyDay == index
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  )
                : null,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }

  Future<void> _openDay(NutritionStatisticsPeriodDay day) async {
    final record = day.data?.record;
    final openRecall = widget.onOpenRecall;
    if (record == null || openRecall == null) return;
    await openRecall(record);
    if (!mounted) return;
    setState(() => _records = _loadRecords());
  }

  Widget _nutrientCard(
    BuildContext context,
    NutritionStatisticsPeriod current,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final average = current.average(
      (nutrition) => _nutrientValue(_selectedNutrient, nutrition),
    );
    final values = [
      for (final day in current.days)
        if (day.hasChartData)
          _nutrientValue(_selectedNutrient, day.data!.nutrition),
    ];
    final maxY = _chartMax(values);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.nutrition_nutrient_trend,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<_Nutrient>(
                segments: [
                  ButtonSegment(
                    value: _Nutrient.carbs,
                    label: Text(l10n.nutrition_carbs),
                  ),
                  ButtonSegment(
                    value: _Nutrient.protein,
                    label: Text(l10n.protein),
                  ),
                  ButtonSegment(value: _Nutrient.fat, label: Text(l10n.fat)),
                  ButtonSegment(
                    value: _Nutrient.fiber,
                    label: Text(l10n.fibre),
                  ),
                ],
                selected: {_selectedNutrient},
                showSelectedIcon: false,
                onSelectionChanged: (selection) =>
                    setState(() => _selectedNutrient = selection.single),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: _nutrientChart(context, current, maxY),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.nutrition_average_per_recorded_day(_grams(context, average)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _nutrientChart(
    BuildContext context,
    NutritionStatisticsPeriod current,
    double maxY,
  ) {
    final theme = Theme.of(context);
    return Semantics(
      label: _lineChartSemantics(context, current),
      child: ExcludeSemantics(
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: (current.days.length - 1).toDouble(),
            minY: 0,
            maxY: maxY,
            borderData: FlBorderData(show: false),
            gridData: FlGridData(
              drawVerticalLine: false,
              horizontalInterval: maxY / 4,
            ),
            titlesData: _titlesData(context, current),
            lineBarsData: _lineSegments(
              current,
              _selectedNutrient,
              theme.colorScheme.primary,
            ),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                fitInsideHorizontally: true,
                getTooltipItems: (spots) => [
                  for (final spot in spots)
                    LineTooltipItem(
                      '${_tooltipDate(context, current.days[spot.x.round()])} · '
                      '${_grams(context, spot.y)}',
                      TextStyle(color: theme.colorScheme.onInverseSurface),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _comparisonCard(
    BuildContext context,
    NutritionStatisticsPeriod current,
    NutritionStatisticsPeriod previous,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final enoughData =
        current.recordedCount >= 2 && previous.recordedCount >= 2;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: enoughData
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.nutrition_compared_previous_days(_selectedPeriod.days),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _changeRow(
                    context,
                    l10n.nutrition_energy,
                    current.average((value) => value.energyKcal)! -
                        previous.average((value) => value.energyKcal)!,
                    calories: true,
                  ),
                  _changeRow(
                    context,
                    l10n.protein,
                    current.average((value) => value.protein)! -
                        previous.average((value) => value.protein)!,
                  ),
                  _changeRow(
                    context,
                    l10n.fibre,
                    current.average((value) => value.fiber)! -
                        previous.average((value) => value.fiber)!,
                  ),
                ],
              )
            : Text(l10n.nutrition_record_more_comparisons),
      ),
    );
  }

  Widget _changeRow(
    BuildContext context,
    String label,
    double change, {
    bool calories = false,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final rounded = change.abs() < 0.05 ? 0.0 : change;
    final sign = rounded > 0 ? '+' : (rounded < 0 ? '−' : '');
    final magnitude = calories
        ? _numberFormat(context, maximumFractionDigits: 0).format(rounded.abs())
        : _numberFormat(
            context,
            maximumFractionDigits: 1,
          ).format(rounded.abs());
    final value = calories
        ? l10n.nutrition_kcal_per_day('$sign$magnitude')
        : l10n.nutrition_grams_per_day('$sign$magnitude');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Icon(
            rounded > 0
                ? Icons.arrow_upward
                : (rounded < 0 ? Icons.arrow_downward : Icons.remove),
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(value),
        ],
      ),
    );
  }

  FlTitlesData _titlesData(
    BuildContext context,
    NutritionStatisticsPeriod period,
  ) => FlTitlesData(
    topTitles: const AxisTitles(),
    rightTitles: const AxisTitles(),
    leftTitles: const AxisTitles(),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 28,
        getTitlesWidget: (value, meta) {
          final index = value.round();
          if (index < 0 || index >= period.days.length) {
            return const SizedBox.shrink();
          }
          if (period.days.length > 7 &&
              index % 5 != 0 &&
              index != period.days.length - 1) {
            return const SizedBox.shrink();
          }
          final day = period.days[index];
          final locale = Localizations.localeOf(context).toString();
          final label = day.isToday
              ? AppLocalizations.of(context)!.today
              : (period.days.length == 7
                    ? DateFormat.E(locale).format(day.date).substring(0, 1)
                    : DateFormat.d(locale).format(day.date));
          return SideTitleWidget(
            meta: meta,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: day.isToday ? FontWeight.bold : null,
              ),
            ),
          );
        },
      ),
    ),
  );

  List<LineChartBarData> _lineSegments(
    NutritionStatisticsPeriod period,
    _Nutrient nutrient,
    Color color,
  ) {
    final result = <LineChartBarData>[];
    var segment = <FlSpot>[];

    void addSegment() {
      if (segment.isEmpty) return;
      result.add(LineChartBarData(spots: segment, color: color, barWidth: 3));
      segment = [];
    }

    for (var index = 0; index < period.days.length; index++) {
      final day = period.days[index];
      if (!day.hasChartData) {
        addSegment();
        continue;
      }
      segment.add(
        FlSpot(index.toDouble(), _nutrientValue(nutrient, day.data!.nutrition)),
      );
    }
    addSegment();
    return result;
  }

  double _nutrientValue(_Nutrient nutrient, NutritionProfile nutrition) =>
      switch (nutrient) {
        _Nutrient.carbs => nutrition.carbs,
        _Nutrient.protein => nutrition.protein,
        _Nutrient.fat => nutrition.fat,
        _Nutrient.fiber => nutrition.fiber,
      };

  Widget _value(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Text(value),
      ],
    ),
  );

  String _lineChartSemantics(
    BuildContext context,
    NutritionStatisticsPeriod period,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final nutrient = switch (_selectedNutrient) {
      _Nutrient.carbs => l10n.nutrition_carbs,
      _Nutrient.protein => l10n.protein,
      _Nutrient.fat => l10n.fat,
      _Nutrient.fiber => l10n.fibre,
    };
    return '$nutrient. ${[for (final day in period.days) _accessibleDayLabel(context, day, day.hasChartData ? _grams(context, _nutrientValue(_selectedNutrient, day.data!.nutrition)) : null)].join('; ')}';
  }

  String _accessibleDayLabel(
    BuildContext context,
    NutritionStatisticsPeriodDay day,
    String? value,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final date = day.isToday
        ? l10n.nutrition_today_so_far
        : DateFormat.yMMMd(
            Localizations.localeOf(context).toString(),
          ).format(day.date);
    return value == null
        ? l10n.nutrition_chart_day_missing(date)
        : l10n.nutrition_chart_day_value(date, value);
  }

  String _tooltipDate(BuildContext context, NutritionStatisticsPeriodDay day) {
    if (day.isToday) {
      return AppLocalizations.of(context)!.nutrition_today_so_far;
    }
    return DateFormat(
      'EEE, d MMM',
      Localizations.localeOf(context).toString(),
    ).format(day.date);
  }

  String _periodLabel(BuildContext context, DateTime start, DateTime end) {
    final locale = Localizations.localeOf(context).toString();
    if (start.year == end.year && start.month == end.month) {
      return '${start.day}–${end.day} ${DateFormat.MMMM(locale).format(end)}';
    }
    if (start.year == end.year) {
      return '${DateFormat('d MMM', locale).format(start)}–'
          '${DateFormat('d MMM', locale).format(end)}';
    }
    return '${DateFormat.yMMMd(locale).format(start)}–'
        '${DateFormat.yMMMd(locale).format(end)}';
  }

  String _calories(BuildContext context, double? value) => value == null
      ? '—'
      : '${_numberFormat(context, maximumFractionDigits: 0).format(value)} kcal';

  String _grams(BuildContext context, double? value) => value == null
      ? '—'
      : '${_numberFormat(context, maximumFractionDigits: 1).format(value)} g';

  NumberFormat _numberFormat(
    BuildContext context, {
    required int maximumFractionDigits,
  }) =>
      NumberFormat.decimalPattern(Localizations.localeOf(context).toString())
        ..maximumFractionDigits = maximumFractionDigits;

  double _chartMax(Iterable<double> values) {
    var maximum = 0.0;
    for (final value in values) {
      maximum = math.max(maximum, value);
    }
    return math.max(1, maximum * 1.15);
  }
}

class NutritionStatisticsDay {
  final int studyDaySnapshot;
  final DateTime date;
  final NutritionProfile nutrition;
  final bool isRecorded;
  final bool hasData;
  final NutritionRecallRecord? record;

  const NutritionStatisticsDay({
    required this.studyDaySnapshot,
    required this.date,
    required this.nutrition,
    required this.isRecorded,
    required this.hasData,
    required this.record,
  });
}

class NutritionStatisticsPeriodDay {
  final DateTime date;
  final NutritionStatisticsDay? data;
  final bool isToday;

  const NutritionStatisticsPeriodDay({
    required this.date,
    required this.data,
    required this.isToday,
  });

  bool get isRecorded => data?.isRecorded ?? false;
  bool get hasChartData => isRecorded || (isToday && (data?.hasData ?? false));
}

class NutritionStatisticsPeriod {
  final List<NutritionStatisticsPeriodDay> days;

  const NutritionStatisticsPeriod(this.days);

  DateTime get startDate => days.first.date;
  DateTime get endDate => days.last.date;
  int get recordedCount => days.where((day) => day.isRecorded).length;

  double? average(double Function(NutritionProfile nutrition) value) {
    final recordedDays = days.where((day) => day.isRecorded).toList();
    if (recordedDays.isEmpty) return null;
    return recordedDays.fold<double>(
          0,
          (sum, day) => sum + value(day.data!.nutrition),
        ) /
        recordedDays.length;
  }
}

List<NutritionStatisticsDay> nutritionStatisticsDays(
  List<NutritionRecallRecord> records, {
  DailyRecall? activeRecall,
  int? activeStudyDay,
  String? activePeriodId,
  DateTime? today,
}) {
  final mergedRecords = [...records];
  final activeDay = activeStudyDay ?? activeRecall?.studyDaySnapshot;
  if (activeRecall != null && activeDay != null) {
    bool matchesActiveRecord(NutritionRecallRecord record) =>
        record.studyDaySnapshot == activeDay &&
        (activePeriodId != null
            ? record.periodId == activePeriodId
            : record.recall.id == activeRecall.id);

    NutritionRecallRecord? replaced;
    for (final record in mergedRecords) {
      if (matchesActiveRecord(record)) {
        replaced = record;
        break;
      }
    }
    mergedRecords.removeWhere(matchesActiveRecord);
    mergedRecords.add(
      NutritionRecallRecord(
        recall: activeRecall,
        taskId: replaced?.taskId ?? '',
        periodId: activePeriodId,
        interventionId: replaced?.interventionId ?? '',
        studyDaySnapshot: activeDay,
        progress: replaced?.progress,
      ),
    );
  }

  final byDay = <int, List<NutritionRecallRecord>>{};
  for (final record in mergedRecords) {
    byDay.putIfAbsent(record.studyDaySnapshot, () => []).add(record);
  }
  final currentDate = DateUtils.dateOnly(today ?? DateTime.now());
  final days = byDay.entries.map((entry) {
    final recordsForDay = entry.value;
    final date = DateUtils.dateOnly(recordsForDay.first.recall.date.toLocal());
    final foods = [
      for (final record in recordsForDay)
        for (final meal in record.recall.meals)
          if (!meal.isSkipped) ...meal.foods,
    ];
    final completed = recordsForDay.where(
      (record) => record.recall.entryCompletedAt != null,
    );
    final isToday = DateUtils.isSameDay(date, currentDate);
    return NutritionStatisticsDay(
      studyDaySnapshot: entry.key,
      date: date,
      nutrition: sumNutritionFoods(foods),
      isRecorded: !isToday || completed.isNotEmpty,
      hasData: foods.isNotEmpty || recordsForDay.isNotEmpty,
      record: completed.isNotEmpty ? completed.first : recordsForDay.first,
    );
  }).toList()..sort((left, right) => left.date.compareTo(right.date));
  return days;
}

NutritionStatisticsPeriod nutritionStatisticsPeriod(
  List<NutritionStatisticsDay> statisticsDays, {
  required DateTime endDate,
  required int dayCount,
  DateTime? today,
}) {
  final end = DateUtils.dateOnly(endDate);
  final start = addCalendarDays(end, -(dayCount - 1));
  final currentDate = DateUtils.dateOnly(today ?? DateTime.now());
  final byDate = {
    for (final day in statisticsDays)
      _dateKey(DateUtils.dateOnly(day.date)): day,
  };
  return NutritionStatisticsPeriod([
    for (var offset = 0; offset < dayCount; offset++)
      NutritionStatisticsPeriodDay(
        date: addCalendarDays(start, offset),
        data: byDate[_dateKey(addCalendarDays(start, offset))],
        isToday: DateUtils.isSameDay(
          addCalendarDays(start, offset),
          currentDate,
        ),
      ),
  ]);
}

DateTime addCalendarDays(DateTime date, int days) =>
    DateTime(date.year, date.month, date.day + days);

String _dateKey(DateTime date) => '${date.year}-${date.month}-${date.day}';
