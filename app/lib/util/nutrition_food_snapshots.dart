import 'package:studyu_core/core.dart';

/// Applies definition data while retaining fields owned by the logged entry.
FoodEntry applyNutritionFoodSnapshot(FoodEntry logged, FoodEntry definition) {
  final updated = FoodEntry.fromJson(definition.toJson());
  final definitionAmount = definition.amount;
  if (definitionAmount.isFinite && definitionAmount > 0) {
    _scaleNutrition(updated.nutrition, logged.amount / definitionAmount);
  }
  return FoodEntry(
    id: logged.id,
    foodId: definition.foodId,
    foodVersionId: definition.foodVersionId,
    entryType: updated.entryType,
    name: updated.name,
    brandName: updated.brandName,
    description: updated.description,
    amount: logged.amount,
    unit: logged.unit,
    servingSizeGrams: logged.servingSizeGrams,
    portionReference: logged.portionReference,
    portionEstimationMethod: logged.portionEstimationMethod,
    portionState: logged.portionState,
    yieldFactor: logged.yieldFactor,
    ediblePortion: logged.ediblePortion,
    nutrition: updated.nutrition,
    foodCode: updated.foodCode,
    externalId: updated.externalId,
    source: updated.source,
    confidenceScore: updated.confidenceScore,
    templateId: logged.templateId,
    createdAt: logged.createdAt,
    modifiedAt: logged.modifiedAt,
    originalValues: updated.originalValues,
    parentEntryId: logged.parentEntryId,
    preparationDetails: updated.preparationDetails,
    componentFoods: updated.componentFoods,
    componentSnapshots: updated.componentSnapshots,
  );
}

DailyRecall replaceNutritionFoodSnapshots(
  DailyRecall recall,
  FoodEntry definition,
) {
  final updated = DailyRecall.fromJson(recall.toJson());
  for (final meal in updated.meals) {
    for (var index = 0; index < meal.foods.length; index++) {
      final logged = meal.foods[index];
      if (logged.foodId == definition.foodId) {
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
