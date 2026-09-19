import 'package:json_annotation/json_annotation.dart';

import 'package:studyu_core/src/models/medication/medication_active_ingredient.dart';
import 'package:studyu_core/src/models/medication/medication_dosage_form.dart';

part 'medication_component.g.dart';

@JsonSerializable()
class MedicationComponent {
  final String key;
  final int number;
  final MedicationDosageForm dosageForm;
  final String? description;
  final List<MedicationActiveIngredient> activeIngredients;

  const MedicationComponent({
    required this.key,
    required this.number,
    required this.dosageForm,
    this.description,
    required this.activeIngredients,
  });

  factory MedicationComponent.fromJson(Map<String, dynamic> json) =>
      _$MedicationComponentFromJson(json);

  Map<String, dynamic> toJson() => _$MedicationComponentToJson(this);
}
