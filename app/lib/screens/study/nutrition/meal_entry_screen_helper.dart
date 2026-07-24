import 'dart:convert';

import 'package:studyu_core/core.dart';
import 'package:uuid/uuid.dart';

MealLog cloneMealLog(MealLog meal) => MealLog.fromJson(
  jsonDecode(jsonEncode(meal.toJson())) as Map<String, dynamic>,
);

FoodEntry cloneFoodEntry(FoodEntry food) => FoodEntry.fromJson(
  jsonDecode(jsonEncode(food.toJson())) as Map<String, dynamic>,
);

FoodEntry duplicateFoodEntry(FoodEntry food) {
  final duplicate = cloneFoodEntry(food)
    ..id = const Uuid().v4()
    ..createdAt = DateTime.now()
    ..modifiedAt = null
    ..parentRecipeId = null;
  duplicate.recipeIngredients = duplicate.recipeIngredients
      ?.map(
        (composition) => RecipeComposition.withId(
          recipeId: duplicate.id,
          ingredientId: composition.ingredientId,
          amount: composition.amount,
          unit: composition.unit,
          sortOrder: composition.sortOrder,
        ),
      )
      .toList();
  return duplicate;
}

FoodEntry rescaleFoodAmount(FoodEntry food, double newAmount) {
  if (!food.amount.isFinite || food.amount <= 0) {
    throw ArgumentError.value(food.amount, 'food.amount', 'Must be positive');
  }
  if (!newAmount.isFinite || newAmount <= 0) {
    throw ArgumentError.value(newAmount, 'newAmount', 'Must be positive');
  }

  final scaled = cloneFoodEntry(food);
  final factor = newAmount / food.amount;
  final nutrition = scaled.nutrition;

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
  scaled.amount = newAmount;
  return scaled;
}
