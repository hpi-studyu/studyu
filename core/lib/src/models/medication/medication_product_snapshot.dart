import 'package:json_annotation/json_annotation.dart';

import 'medication_component.dart';
import 'medication_dosage_form.dart';
import 'medication_source.dart';

part 'medication_product_snapshot.g.dart';

@JsonSerializable()
class MedicationProductSnapshot {
  final String pzn;
  final String officialName;
  final int activeIngredientCount;
  final MedicationDosageForm dosageForm;
  final List<MedicationComponent> components;
  final MedicationSource source;

  const MedicationProductSnapshot({
    required this.pzn,
    required this.officialName,
    required this.activeIngredientCount,
    required this.dosageForm,
    required this.components,
    required this.source,
  });

  factory MedicationProductSnapshot.fromJson(Map<String, dynamic> json) =>
      _$MedicationProductSnapshotFromJson(json);

  Map<String, dynamic> toJson() => _$MedicationProductSnapshotToJson(this);
}
