import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/util/nutrition_food_snapshots.dart';
import 'package:studyu_core/core.dart';

void main() {
  test(
    'definition replacement preserves logged identity and serving state',
    () {
      final logged =
          _food(
              id: 'entry',
              foodId: 'food',
              versionId: 'old-version',
              name: 'Old',
              amount: 2,
              energy: 200,
            )
            ..unit = 'logged servings'
            ..servingSizeGrams = 80
            ..portionReference = 'logged reference'
            ..templateId = 'template'
            ..modifiedAt = DateTime.utc(2026, 7, 15, 9)
            ..parentEntryId = 'meal';
      final definition =
          _food(
              id: 'definition-snapshot',
              foodId: 'food',
              versionId: 'new-version',
              name: 'New',
              amount: 1,
              energy: 150,
            )
            ..unit = 'new serving'
            ..servingSizeGrams = 120
            ..portionReference = 'new reference'
            ..originalValues = const {'reusable': true};

      final updated = applyNutritionFoodSnapshot(logged, definition);

      expect(updated.id, 'entry');
      expect(updated.foodId, 'food');
      expect(updated.foodVersionId, 'new-version');
      expect(updated.name, 'New');
      expect(updated.amount, 2);
      expect(updated.unit, 'new serving');
      expect(updated.servingSizeGrams, 120);
      expect(updated.portionReference, 'new reference');
      expect(updated.originalValues, {'reusable': true});
      expect(updated.templateId, 'template');
      expect(updated.createdAt, logged.createdAt);
      expect(updated.modifiedAt, logged.modifiedAt);
      expect(updated.parentEntryId, 'meal');
      expect(updated.nutrition.energyKcal, 300);
    },
  );

  test('entry-specific replacement leaves same-food siblings unchanged', () {
    final selected = _food(
      id: 'selected-entry',
      foodId: 'food',
      versionId: 'old-version',
      name: 'Selected old',
      amount: 2,
      energy: 200,
    );
    final sibling = _food(
      id: 'sibling-entry',
      foodId: 'food',
      versionId: 'old-version',
      name: 'Sibling old',
      amount: 3,
      energy: 300,
    );
    final recall = DailyRecall(
      id: 'recall',
      date: DateTime.utc(2026, 7, 15),
      recallMode: RecallMode.realtimeRecord,
      entryStartedAt: DateTime.utc(2026, 7, 15, 8),
      meals: [
        MealLog(
          id: 'meal',
          mealType: MealType.breakfast,
          mealContext: MealContext.home,
          timezone: 'UTC',
          isSkipped: false,
          foods: [selected, sibling],
        ),
      ],
    );
    final definition = _food(
      id: 'definition-snapshot',
      foodId: 'food',
      versionId: 'new-version',
      name: 'New',
      amount: 1,
      energy: 150,
    );

    final updated = replaceNutritionFoodSnapshots(
      recall,
      definition,
      entryId: selected.id,
    );

    expect(updated.meals.single.foods.first.name, 'New');
    expect(updated.meals.single.foods.last.name, 'Sibling old');
    expect(updated.meals.single.foods.last.foodVersionId, 'old-version');
  });

  test('saved meal component snapshots are replaced but not cascaded', () {
    final oldComponent = _food(
      id: 'component-entry',
      foodId: 'component',
      versionId: 'component-v1',
      name: 'Component old',
      amount: 1,
      energy: 50,
    );
    final loggedMeal = _food(
      id: 'meal-entry',
      foodId: 'meal-definition',
      versionId: 'meal-v1',
      name: 'Meal old',
      amount: 1,
      energy: 50,
    )..componentSnapshots = [oldComponent];
    final newComponent = FoodEntry.fromJson(oldComponent.toJson())
      ..name = 'Component embedded in meal v2';
    final mealDefinition = FoodEntry.fromJson(loggedMeal.toJson())
      ..id = 'meal-snapshot'
      ..foodVersionId = 'meal-v2'
      ..name = 'Meal new'
      ..componentSnapshots = [newComponent];

    final updated = applyNutritionFoodSnapshot(loggedMeal, mealDefinition);

    expect(updated.foodVersionId, 'meal-v2');
    expect(
      updated.componentSnapshots!.single.name,
      'Component embedded in meal v2',
    );
    expect(oldComponent.name, 'Component old');
  });
}

FoodEntry _food({
  required String id,
  required String foodId,
  required String versionId,
  required String name,
  required double amount,
  required double energy,
}) => FoodEntry(
  id: id,
  foodId: foodId,
  foodVersionId: versionId,
  entryType: FoodEntryType.singleIngredient,
  name: name,
  amount: amount,
  unit: 'serving',
  servingSizeGrams: 100,
  portionEstimationMethod: PortionEstimationMethod.standardUnit,
  portionState: PortionState.asServed,
  nutrition: NutritionProfile(
    energyKcal: energy,
    protein: 1,
    carbs: 2,
    fat: 3,
    sugars: 0,
    fiber: 0,
    saturatedFat: 0,
    transFat: 0,
    cholesterol: 0,
    sodium: 0,
    waterContent: 0,
    micros: const {},
  ),
  source: FoodSource.manual,
  confidenceScore: 1,
  createdAt: DateTime.utc(2026, 7, 15),
  originalValues: const {},
);
