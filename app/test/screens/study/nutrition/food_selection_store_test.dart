import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/screens/study/nutrition/food_search_screen.dart';
import 'package:studyu_core/core.dart' as studyu;

void main() {
  test('selection store combines quantities and materializes scaled food', () {
    final store = FoodSelectionStore();
    final entry = food(id: 'apple', calories: 95);

    store
      ..addOrIncrement('apple', entry)
      ..addOrIncrement('apple', entry);

    expect(store.itemCount, 1);
    expect(store.servingCount, 2);
    expect(store.knownCalories(), 190);
    expect(store.materialize().single.amount, 2);

    store.decrement('apple');
    expect(store.itemFor('apple')?.quantity, 1);

    store.decrement('apple');
    expect(store.isEmpty, isTrue);
  });

  test('canonical key prefers template and external identities', () {
    expect(
      canonicalFoodSelectionKey(
        food(id: 'local', templateId: 'template-id', externalId: 'external-id'),
      ),
      'template:template-id',
    );
    expect(
      canonicalFoodSelectionKey(
        food(id: 'local', source: studyu.FoodSource.usda, externalId: '123'),
      ),
      'usda:id:123',
    );
  });
}

studyu.FoodEntry food({
  required String id,
  double calories = 100,
  String? templateId,
  String? externalId,
  studyu.FoodSource source = studyu.FoodSource.manual,
}) => studyu.FoodEntry(
  id: id,
  entryType: studyu.FoodEntryType.singleIngredient,
  name: 'Apple',
  amount: 1,
  unit: 'serving',
  servingSizeGrams: 100,
  portionEstimationMethod: studyu.PortionEstimationMethod.standardUnit,
  portionState: studyu.PortionState.asServed,
  nutrition: studyu.NutritionProfile(
    energyKcal: calories,
    protein: 1,
    carbs: 1,
    fat: 1,
    sugars: 0,
    fiber: 0,
    saturatedFat: 0,
    transFat: 0,
    cholesterol: 0,
    sodium: 0,
    waterContent: 0,
    micros: const {},
  ),
  templateId: templateId,
  externalId: externalId,
  source: source,
  confidenceScore: 1,
  createdAt: DateTime.utc(2024),
  originalValues: const {},
);
