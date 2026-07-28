import 'package:studyu_core/core.dart';

/// Applies reusable definition fields while retaining occurrence-owned fields.
///
/// Occurrences own identity, quantity, template/meal placement, and logged
/// timestamps. Every other field, including serving metadata and composition,
/// comes from the reusable definition.
FoodEntry applyNutritionFoodSnapshot(FoodEntry logged, FoodEntry definition) {
  final updated = FoodEntry.fromJson(definition.toJson());
  final definitionAmount = definition.amount;
  if (definitionAmount.isFinite && definitionAmount > 0) {
    _scaleNutrition(updated.nutrition, logged.amount / definitionAmount);
  }
  return updated
    ..id = logged.id
    ..amount = logged.amount
    ..templateId = logged.templateId
    ..createdAt = logged.createdAt
    ..modifiedAt = logged.modifiedAt
    ..parentEntryId = logged.parentEntryId;
}

DailyRecall replaceNutritionFoodSnapshots(
  DailyRecall recall,
  FoodEntry definition, {
  String? entryId,
}) {
  final updated = DailyRecall.fromJson(recall.toJson());
  for (final meal in updated.meals) {
    for (var index = 0; index < meal.foods.length; index++) {
      final logged = meal.foods[index];
      if (logged.foodId == definition.foodId &&
          (entryId == null || logged.id == entryId)) {
        meal.foods[index] = applyNutritionFoodSnapshot(logged, definition);
      }
    }
  }
  return updated;
}

void _scaleNutrition(NutritionProfile nutrition, double factor) {
  nutrition
    ..energyKcal *= factor
    ..protein *= factor
    ..carbs *= factor
    ..fat *= factor
    ..sugars *= factor
    ..fiber *= factor
    ..saturatedFat *= factor
    ..transFat *= factor
    ..cholesterol *= factor
    ..sodium *= factor
    ..waterContent *= factor
    ..micros = nutrition.micros.map(
      (nutrient, value) => MapEntry(nutrient, value * factor),
    );
}
