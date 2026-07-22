import 'package:flutter/material.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_core/core.dart';

class NutritionSummaryCard extends StatelessWidget {
  final NutritionProfile nutrition;
  final String? title;
  final String? subtitle;

  const NutritionSummaryCard({
    required this.nutrition,
    this.title,
    this.subtitle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final cardTitle = title ?? l10n.nutrition_summary;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: Icon(Icons.pie_chart, color: theme.colorScheme.primary),
        title: Text(
          cardTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (subtitle != null) ...[
              Text(subtitle!),
              const SizedBox(height: 8),
            ],
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.energy_kcal, style: theme.textTheme.bodySmall),
                    Text(
                      '${nutrition.energyKcal.toStringAsFixed(0)} kcal',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.protein_g, style: theme.textTheme.bodySmall),
                    Text(
                      '${nutrition.protein.toStringAsFixed(1)}g',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.carbs_g, style: theme.textTheme.bodySmall),
                    Text(
                      '${nutrition.carbs.toStringAsFixed(1)}g',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.fat_g, style: theme.textTheme.bodySmall),
                    Text(
                      '${nutrition.fat.toStringAsFixed(1)}g',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMacroDistributionBar(context),
                const Divider(height: 24),
                ExpansionTile(
                  title: Text(l10n.detailed_nutrients),
                  leading: const Icon(Icons.more_horiz),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          _buildDetailedNutrient(
                            l10n.fiber_g,
                            nutrition.fiber,
                            'g',
                          ),
                          _buildDetailedNutrient(
                            l10n.sugars_g,
                            nutrition.sugars,
                            'g',
                          ),
                          _buildDetailedNutrient(
                            l10n.saturated_fat_g,
                            nutrition.saturatedFat,
                            'g',
                          ),
                          _buildDetailedNutrient(
                            'Trans Fat',
                            nutrition.transFat,
                            'g',
                          ),
                          _buildDetailedNutrient(
                            'Cholesterol',
                            nutrition.cholesterol,
                            'mg',
                          ),
                          _buildDetailedNutrient(
                            l10n.sodium_mg,
                            nutrition.sodium,
                            'mg',
                          ),
                          _buildDetailedNutrient(
                            'Water Content',
                            nutrition.waterContent,
                            'g',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroDistributionBar(BuildContext context) {
    final totalCals =
        (nutrition.protein * 4) + (nutrition.carbs * 4) + (nutrition.fat * 9);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (totalCals == 0) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.3,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              Icons.info_outline,
              size: 24,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.no_data_yet,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.start_tracking_nutrition,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.7,
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final proteinPercent = (nutrition.protein * 4 / totalCals) * 100;
    final carbsPercent = (nutrition.carbs * 4 / totalCals) * 100;
    final fatPercent = (nutrition.fat * 9 / totalCals) * 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.calorie_distribution,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Row(
            children: [
              if (proteinPercent > 0)
                Expanded(
                  flex: proteinPercent.round(),
                  child: Container(
                    height: 24,
                    color: Colors.blue,
                    alignment: Alignment.center,
                    child: proteinPercent >= 15
                        ? Text(
                            '${proteinPercent.round()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                ),
              if (carbsPercent > 0)
                Expanded(
                  flex: carbsPercent.round(),
                  child: Container(
                    height: 24,
                    color: Colors.green,
                    alignment: Alignment.center,
                    child: carbsPercent >= 15
                        ? Text(
                            '${carbsPercent.round()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                ),
              if (fatPercent > 0)
                Expanded(
                  flex: fatPercent.round(),
                  child: Container(
                    height: 24,
                    color: Colors.purple,
                    alignment: Alignment.center,
                    child: fatPercent >= 15
                        ? Text(
                            '${fatPercent.round()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedNutrient(String label, double value, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            '${value.toStringAsFixed(1)} $unit',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class DailyNutritionSummaryCard extends StatelessWidget {
  final DailyRecall dailyRecall;

  const DailyNutritionSummaryCard({required this.dailyRecall, super.key});

  NutritionProfile _calculateDailyNutrition() {
    double totalEnergy = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    double totalSugars = 0;
    double totalFiber = 0;
    double totalSaturatedFat = 0;
    double totalTransFat = 0;
    double totalCholesterol = 0;
    double totalSodium = 0;
    double totalWater = 0;
    final Map<String, double> totalMicros = {};

    for (final meal in dailyRecall.meals) {
      if (!meal.isSkipped) {
        for (final food in meal.foods) {
          totalEnergy += food.nutrition.energyKcal;
          totalProtein += food.nutrition.protein;
          totalCarbs += food.nutrition.carbs;
          totalFat += food.nutrition.fat;
          totalSugars += food.nutrition.sugars;
          totalFiber += food.nutrition.fiber;
          totalSaturatedFat += food.nutrition.saturatedFat;
          totalTransFat += food.nutrition.transFat;
          totalCholesterol += food.nutrition.cholesterol;
          totalSodium += food.nutrition.sodium;
          totalWater += food.nutrition.waterContent;

          food.nutrition.micros.forEach((key, value) {
            totalMicros[key] = (totalMicros[key] ?? 0) + value;
          });
        }
      }
    }

    return NutritionProfile(
      energyKcal: totalEnergy,
      protein: totalProtein,
      carbs: totalCarbs,
      fat: totalFat,
      sugars: totalSugars,
      fiber: totalFiber,
      saturatedFat: totalSaturatedFat,
      transFat: totalTransFat,
      cholesterol: totalCholesterol,
      sodium: totalSodium,
      waterContent: totalWater,
      micros: totalMicros,
    );
  }

  @override
  Widget build(BuildContext context) {
    final nutrition = _calculateDailyNutrition();
    final l10n = AppLocalizations.of(context)!;
    return NutritionSummaryCard(
      nutrition: nutrition,
      title: l10n.daily_nutrition_total,
    );
  }
}

class MealNutritionSummaryCard extends StatelessWidget {
  final MealLog meal;

  const MealNutritionSummaryCard({required this.meal, super.key});

  NutritionProfile _calculateMealNutrition() {
    double totalEnergy = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    double totalSugars = 0;
    double totalFiber = 0;
    double totalSaturatedFat = 0;
    double totalTransFat = 0;
    double totalCholesterol = 0;
    double totalSodium = 0;
    double totalWater = 0;
    final Map<String, double> totalMicros = {};

    for (final food in meal.foods) {
      totalEnergy += food.nutrition.energyKcal;
      totalProtein += food.nutrition.protein;
      totalCarbs += food.nutrition.carbs;
      totalFat += food.nutrition.fat;
      totalSugars += food.nutrition.sugars;
      totalFiber += food.nutrition.fiber;
      totalSaturatedFat += food.nutrition.saturatedFat;
      totalTransFat += food.nutrition.transFat;
      totalCholesterol += food.nutrition.cholesterol;
      totalSodium += food.nutrition.sodium;
      totalWater += food.nutrition.waterContent;

      food.nutrition.micros.forEach((key, value) {
        totalMicros[key] = (totalMicros[key] ?? 0) + value;
      });
    }

    return NutritionProfile(
      energyKcal: totalEnergy,
      protein: totalProtein,
      carbs: totalCarbs,
      fat: totalFat,
      sugars: totalSugars,
      fiber: totalFiber,
      saturatedFat: totalSaturatedFat,
      transFat: totalTransFat,
      cholesterol: totalCholesterol,
      sodium: totalSodium,
      waterContent: totalWater,
      micros: totalMicros,
    );
  }

  @override
  Widget build(BuildContext context) {
    final nutrition = _calculateMealNutrition();
    final l10n = AppLocalizations.of(context)!;
    return NutritionSummaryCard(
      nutrition: nutrition,
      title: l10n.meal_nutrition,
    );
  }
}
