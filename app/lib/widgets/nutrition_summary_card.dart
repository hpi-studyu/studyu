import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';

class NutritionSummaryCard extends StatelessWidget {
  final NutritionProfile nutrition;
  final String title;

  const NutritionSummaryCard({
    required this.nutrition,
    this.title = 'Nutrition Summary',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${nutrition.energyKcal.round()} kcal',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 64,
                  width: 64,
                  child: Stack(
                    children: [
                      Center(
                        child: CircularProgressIndicator(
                          value: 1.0, // Full circle background
                          color: theme.colorScheme.surfaceContainerHighest,
                          strokeWidth: 8,
                        ),
                      ),
                      Center(
                        child: CircularProgressIndicator(
                          value: (nutrition.energyKcal / 2000).clamp(
                            0.0,
                            1.0,
                          ), // Example target 2000
                          color: theme.colorScheme.primary,
                          strokeWidth: 8,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Center(
                        child: Icon(
                          Icons.local_fire_department,
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildMacroPill(
                    context,
                    'Protein',
                    nutrition.protein,
                    'g',
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMacroPill(
                    context,
                    'Carbs',
                    nutrition.carbs,
                    'g',
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMacroPill(
                    context,
                    'Fat',
                    nutrition.fat,
                    'g',
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ExpansionTile(
              title: Text(
                'More Details',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ),
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              dense: true,
              shape: const Border(),
              children: [
                const Divider(),
                _buildDetailedNutrient('Fiber', nutrition.fiber, 'g'),
                _buildDetailedNutrient('Sugars', nutrition.sugars, 'g'),
                _buildDetailedNutrient(
                  'Saturated Fat',
                  nutrition.saturatedFat,
                  'g',
                ),
                _buildDetailedNutrient('Sodium', nutrition.sodium, 'mg'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroPill(
    BuildContext context,
    String label,
    double value,
    String unit,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${value.round()}$unit',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedNutrient(String label, double value, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            '${value.toStringAsFixed(1)} $unit',
            style: const TextStyle(fontWeight: FontWeight.w500),
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
    Map<String, double> totalMicros = {};

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
    return NutritionSummaryCard(
      nutrition: nutrition,
      title: 'Daily Nutrition Total',
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
    Map<String, double> totalMicros = {};

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
    return NutritionSummaryCard(nutrition: nutrition, title: 'Meal Nutrition');
  }
}
