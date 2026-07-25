import 'package:json_annotation/json_annotation.dart';

part 'nutrition_profile.g.dart';

@JsonSerializable()
class NutritionProfile {
  double energyKcal;
  double protein;
  double carbs;
  double fat;
  double sugars;
  double fiber;
  double saturatedFat;
  double transFat;
  double cholesterol;
  double sodium;
  double waterContent;
  Map<String, double> micros;

  /// Nutrients missing from the source data; deliberately not persisted.
  @JsonKey(includeFromJson: false, includeToJson: false)
  Set<String> unavailableNutrients;

  /// Number of source items represented by this profile with missing data.
  @JsonKey(includeFromJson: false, includeToJson: false)
  int unavailableItemCount;

  NutritionProfile({
    required this.energyKcal,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.sugars,
    required this.fiber,
    required this.saturatedFat,
    required this.transFat,
    required this.cholesterol,
    required this.sodium,
    required this.waterContent,
    required this.micros,
    this.unavailableNutrients = const {},
    this.unavailableItemCount = 0,
  });

  factory NutritionProfile.fromJson(Map<String, dynamic> json) =>
      _$NutritionProfileFromJson(json);

  Map<String, dynamic> toJson() => _$NutritionProfileToJson(this);

  @override
  String toString() => toJson().toString();
}
