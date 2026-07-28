import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/src/models/nutrition/food_entry.dart';

part 'nutrition_food_definition.g.dart';

/// Subject-scoped active definition and its immutable snapshot revision.
@JsonSerializable()
class NutritionFoodDefinition {
  final String id;
  final String subjectId;
  final String kind;
  final String currentVersionId;
  final DateTime? deletedAt;
  final FoodEntry snapshot;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NutritionFoodDefinition({
    required this.id,
    required this.subjectId,
    required this.kind,
    required this.currentVersionId,
    required this.deletedAt,
    required this.snapshot,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NutritionFoodDefinition.fromJson(Map<String, dynamic> json) =>
      _$NutritionFoodDefinitionFromJson(json);

  Map<String, dynamic> toJson() => _$NutritionFoodDefinitionToJson(this);
}

/// Canonical RPC result; progress rows are returned as raw Supabase payloads.
@JsonSerializable()
class NutritionFoodMutationResult {
  final NutritionFoodDefinition definition;
  final List<Map<String, dynamic>> progress;

  const NutritionFoodMutationResult({
    required this.definition,
    required this.progress,
  });

  factory NutritionFoodMutationResult.fromJson(Map<String, dynamic> json) =>
      _$NutritionFoodMutationResultFromJson(json);

  Map<String, dynamic> toJson() => _$NutritionFoodMutationResultToJson(this);
}
