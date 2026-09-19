import 'package:json_annotation/json_annotation.dart';

part 'medication_active_ingredient.g.dart';

@JsonSerializable()
class MedicationActiveIngredient {
  final String key;
  final String name;
  final String? strength;
  final String? bfarmSubstanceId;
  final int rank;

  const MedicationActiveIngredient({
    required this.key,
    required this.name,
    this.strength,
    this.bfarmSubstanceId,
    required this.rank,
  });

  factory MedicationActiveIngredient.fromJson(Map<String, dynamic> json) =>
      _$MedicationActiveIngredientFromJson(json);

  Map<String, dynamic> toJson() => _$MedicationActiveIngredientToJson(this);
}
