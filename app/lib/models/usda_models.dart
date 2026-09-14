import 'package:json_annotation/json_annotation.dart';

part 'usda_models.g.dart';

/// USDA Search Response Model
@JsonSerializable()
class UsdaSearchResponse {
  final int totalHits;
  final int currentPage;
  final int totalPages;
  final List<UsdaFoodItem> foods;

  UsdaSearchResponse({
    required this.totalHits,
    required this.currentPage,
    required this.totalPages,
    required this.foods,
  });

  factory UsdaSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$UsdaSearchResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UsdaSearchResponseToJson(this);
}

/// USDA Food Item Model
@JsonSerializable()
class UsdaFoodItem {
  final int fdcId;
  final String? description;
  final String? dataType; // Foundation, SR Legacy, etc.
  final String? brandOwner;
  final String? brandName;
  final String? gtinUpc;
  final String? ingredients;
  final double? servingSize;
  final String? servingSizeUnit;
  final String? householdServingFullText;
  final List<UsdaFoodNutrient> foodNutrients;
  final List<UsdaFoodPortion>? foodPortions;

  UsdaFoodItem({
    required this.fdcId,
    this.description,
    this.dataType,
    this.brandOwner,
    this.brandName,
    this.gtinUpc,
    this.ingredients,
    this.servingSize,
    this.servingSizeUnit,
    this.householdServingFullText,
    required this.foodNutrients,
    this.foodPortions,
  });

  factory UsdaFoodItem.fromJson(Map<String, dynamic> json) =>
      _$UsdaFoodItemFromJson(json);

  Map<String, dynamic> toJson() => _$UsdaFoodItemToJson(this);

  /// Get nutrient value by nutrient ID
  /// Common IDs: 1008 (Energy/Calories), 1003 (Protein), 1005 (Carbs), 1004 (Fat)
  double? getNutrientValue(int nutrientId) {
    final nutrient = foodNutrients.firstWhere(
      (n) => n.nutrientId == nutrientId,
      orElse: () => UsdaFoodNutrient(nutrientId: nutrientId),
    );
    return nutrient.value;
  }

  /// Get energy in kcal per 100g
  double get energyKcal100g {
    return getNutrientValue(1008) ?? 0.0; // Energy (kcal)
  }

  /// Get protein in g per 100g
  double get protein100g {
    return getNutrientValue(1003) ?? 0.0; // Protein
  }

  /// Get carbohydrates in g per 100g
  double get carbohydrates100g {
    return getNutrientValue(1005) ?? 0.0; // Carbohydrate, by difference
  }

  /// Get total fat in g per 100g
  double get fat100g {
    return getNutrientValue(1004) ?? 0.0; // Total lipid (fat)
  }

  /// Get sugars in g per 100g
  double get sugars100g {
    return getNutrientValue(2000) ?? 0.0; // Sugars, total including NLEA
  }

  /// Get fiber in g per 100g
  double get fiber100g {
    return getNutrientValue(1079) ?? 0.0; // Fiber, total dietary
  }

  /// Get saturated fat in g per 100g
  double get saturatedFat100g {
    return getNutrientValue(1258) ?? 0.0; // Fatty acids, total saturated
  }

  /// Get sodium in mg per 100g
  double get sodium100g {
    return getNutrientValue(1093) ?? 0.0; // Sodium, Na
  }
}

/// USDA Food Nutrient Model
@JsonSerializable()
class UsdaFoodNutrient {
  final int nutrientId;
  final String? nutrientName;
  final String? nutrientNumber;
  final String? unitName;
  final double? value;
  final int? derivationId;
  final String? derivationDescription;

  UsdaFoodNutrient({
    required this.nutrientId,
    this.nutrientName,
    this.nutrientNumber,
    this.unitName,
    this.value,
    this.derivationId,
    this.derivationDescription,
  });

  factory UsdaFoodNutrient.fromJson(Map<String, dynamic> json) =>
      _$UsdaFoodNutrientFromJson(json);

  Map<String, dynamic> toJson() => _$UsdaFoodNutrientToJson(this);
}

/// USDA Food Portion Model
@JsonSerializable()
class UsdaFoodPortion {
  final int id;
  final double amount;
  final String? measureUnit;
  final String? portionDescription;
  final String? modifier;

  UsdaFoodPortion({
    required this.id,
    required this.amount,
    this.measureUnit,
    this.portionDescription,
    this.modifier,
  });

  factory UsdaFoodPortion.fromJson(Map<String, dynamic> json) =>
      _$UsdaFoodPortionFromJson(json);

  Map<String, dynamic> toJson() => _$UsdaFoodPortionToJson(this);
}
