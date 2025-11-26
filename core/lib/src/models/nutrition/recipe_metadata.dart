import 'package:json_annotation/json_annotation.dart';

part 'recipe_metadata.g.dart';

@JsonSerializable()
class RecipeMetadata {
  double rawWeight;
  double cookedWeight;
  double yieldFactor;
  String preparationMethod;
  Map<String, double> retentionFactors;

  RecipeMetadata({
    required this.rawWeight,
    required this.cookedWeight,
    required this.yieldFactor,
    required this.preparationMethod,
    required this.retentionFactors,
  });

  factory RecipeMetadata.fromJson(Map<String, dynamic> json) =>
      _$RecipeMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeMetadataToJson(this);

  @override
  String toString() => toJson().toString();
}

