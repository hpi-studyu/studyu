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
  });

  factory NutritionProfile.fromJson(Map<String, dynamic> json) =>
      _$NutritionProfileFromJson(json);

  Map<String, dynamic> toJson() => _$NutritionProfileToJson(this);

  @override
  String toString() => toJson().toString();
}

