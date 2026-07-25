import 'package:flutter/material.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_core/core.dart';

class NutritionSummaryCard extends StatefulWidget {
  final NutritionProfile nutrition;
  final String? title;
  final String? subtitle;
  final bool inCard;

  const NutritionSummaryCard({
    required this.nutrition,
    this.title,
    this.subtitle,
    this.inCard = false,
    super.key,
  });

  @override
  State<NutritionSummaryCard> createState() => _NutritionSummaryCardState();
}

class _NutritionSummaryCardState extends State<NutritionSummaryCard> {
  bool _detailsExpanded = false;

  @override
  Widget build(BuildContext context) {
    final content = _content(context, includeHeader: true);
    if (!widget.inCard) return content;

    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: content,
      ),
    );
  }

  Widget _content(BuildContext context, {required bool includeHeader}) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: includeHeader ? 16 : 0, bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (includeHeader) ...[
                Text(
                  widget.title ?? l10n.nutrition_summary,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(widget.subtitle!, style: theme.textTheme.bodySmall),
                ],
                const SizedBox(height: 12),
              ],
              Text(
                '${widget.nutrition.energyKcal.round()} kcal',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(l10n.total_energy),
              const SizedBox(height: 20),
              _macronutrients(context),
            ],
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: _details(context),
        ),
      ],
    );
  }

  Widget _macronutrients(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final total =
        widget.nutrition.carbs * 4 +
        widget.nutrition.protein * 4 +
        widget.nutrition.fat * 9;
    final macros = [
      (
        l10n.carbohydrates,
        widget.nutrition.carbs,
        'carbs',
        widget.nutrition.carbs * 4 / (total == 0 ? 1 : total) * 100,
        theme.colorScheme.primary,
      ),
      (
        l10n.protein,
        widget.nutrition.protein,
        'protein',
        widget.nutrition.protein * 4 / (total == 0 ? 1 : total) * 100,
        theme.colorScheme.tertiary,
      ),
      (
        l10n.fat,
        widget.nutrition.fat,
        'fat',
        widget.nutrition.fat * 9 / (total == 0 ? 1 : total) * 100,
        theme.colorScheme.secondary,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.macronutrients,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        for (final macro in macros)
          _macronutrientRow(
            label: macro.$1,
            value: macro.$2,
            keyName: macro.$3,
            percent: macro.$4,
            color: macro.$5,
          ),
        _macronutrientRow(
          label: l10n.fibre,
          value: widget.nutrition.fiber,
          keyName: 'fiber',
        ),
        if (total > 0) ...[
          const SizedBox(height: 10),
          Semantics(
            label: macros.map((m) => '${m.$1} ${m.$4.round()}%').join(', '),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Row(
                children: [
                  for (final macro in macros)
                    Expanded(
                      flex: macro.$4.round().clamp(1, 100),
                      child: ColoredBox(
                        color: macro.$5,
                        child: const SizedBox(height: 8),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _macronutrientRow({
    required String label,
    required double value,
    required String keyName,
    double? percent,
    Color? color,
  }) {
    final theme = Theme.of(context);
    final unavailable = widget.nutrition.unavailableNutrients.contains(keyName);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 14,
            child: color == null
                ? null
                : Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
          ),
          const SizedBox(width: 6),
          Expanded(child: Text(label)),
          SizedBox(
            width: 64,
            child: Text(
              _format(value, 'g', keyName),
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: 48,
            child: Text(
              percent == null
                  ? ''
                  : unavailable
                  ? '—'
                  : '${percent.round()}%',
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _details(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.detailed_nutrients,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () =>
                  setState(() => _detailsExpanded = !_detailsExpanded),
              child: Text(_detailsExpanded ? l10n.hide : l10n.show),
            ),
          ],
        ),
        if (widget.nutrition.unavailableItemCount > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              l10n.some_values_unavailable(
                widget.nutrition.unavailableItemCount,
              ),
              style: theme.textTheme.bodySmall,
            ),
          ),
        if (_detailsExpanded) ...[
          _group(context, l10n.carbohydrates, [
            _row(l10n.fibre, widget.nutrition.fiber, 'g', 'fiber'),
            _row(l10n.sugars_g, widget.nutrition.sugars, 'g', 'sugars'),
          ]),
          _group(context, l10n.fat, [
            _row(
              l10n.saturated_fat_g,
              widget.nutrition.saturatedFat,
              'g',
              'saturatedFat',
            ),
            _row('Trans fat', widget.nutrition.transFat, 'g', 'transFat'),
          ]),
          _group(context, l10n.other, [
            _row(
              'Cholesterol',
              widget.nutrition.cholesterol,
              'mg',
              'cholesterol',
            ),
            _row(l10n.sodium_mg, widget.nutrition.sodium, 'mg', 'sodium'),
            _row('Water', widget.nutrition.waterContent, 'g', 'waterContent'),
          ]),
        ],
      ],
    );
  }

  Widget _group(BuildContext context, String title, List<Widget> rows) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          ...rows,
        ],
      ),
    );
  }

  Widget _row(String label, double value, String unit, String key) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label), Text(_format(value, unit, key))],
    ),
  );

  String _format(double value, String unit, String key) {
    if (widget.nutrition.unavailableNutrients.contains(key)) return '—';
    if (unit == 'mg') return '${value.round()} mg';
    if (value == 0) return '0 g';
    return '${value.toStringAsFixed(1).replaceFirst(RegExp(r'\.0$'), '')} g';
  }
}

class DailyNutritionSummaryCard extends StatelessWidget {
  final DailyRecall dailyRecall;
  const DailyNutritionSummaryCard({required this.dailyRecall, super.key});

  @override
  Widget build(BuildContext context) => NutritionSummaryCard(
    nutrition: _sumFoods([
      for (final meal in dailyRecall.meals)
        if (!meal.isSkipped) ...meal.foods,
    ]),
    title: AppLocalizations.of(context)!.daily_nutrition_total,
    inCard: true,
  );
}

class MealNutritionSummaryCard extends StatelessWidget {
  final MealLog meal;
  const MealNutritionSummaryCard({required this.meal, super.key});

  @override
  Widget build(BuildContext context) => NutritionSummaryCard(
    nutrition: _sumFoods(meal.foods),
    title: AppLocalizations.of(context)!.meal_nutrition,
  );
}

NutritionProfile _sumFoods(List<FoodEntry> foods) {
  double energy = 0;
  double protein = 0;
  double carbs = 0;
  double fat = 0;
  double sugars = 0;
  double fiber = 0;
  double saturatedFat = 0;
  double transFat = 0;
  double cholesterol = 0;
  double sodium = 0;
  double water = 0;
  final micros = <String, double>{};
  final unavailable = <String>{};
  var unavailableItems = 0;
  for (final food in foods) {
    final n = food.nutrition;
    energy += n.energyKcal;
    protein += n.protein;
    carbs += n.carbs;
    fat += n.fat;
    sugars += n.sugars;
    fiber += n.fiber;
    saturatedFat += n.saturatedFat;
    transFat += n.transFat;
    cholesterol += n.cholesterol;
    sodium += n.sodium;
    water += n.waterContent;
    n.micros.forEach((key, value) => micros[key] = (micros[key] ?? 0) + value);
    unavailable.addAll(n.unavailableNutrients);
    if (n.unavailableNutrients.isNotEmpty) {
      unavailableItems += n.unavailableItemCount == 0
          ? 1
          : n.unavailableItemCount;
    }
  }
  return NutritionProfile(
    energyKcal: energy,
    protein: protein,
    carbs: carbs,
    fat: fat,
    sugars: sugars,
    fiber: fiber,
    saturatedFat: saturatedFat,
    transFat: transFat,
    cholesterol: cholesterol,
    sodium: sodium,
    waterContent: water,
    micros: micros,
    unavailableNutrients: unavailable,
    unavailableItemCount: unavailableItems,
  );
}
