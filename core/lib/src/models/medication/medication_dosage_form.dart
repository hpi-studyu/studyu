import 'package:json_annotation/json_annotation.dart';

part 'medication_dosage_form.g.dart';

@JsonSerializable()
class MedicationDosageForm {
  final String? patientFriendlyShort;
  final String? patientFriendlyLong;
  final String? bfarmName;
  final String? bfarmTermId;

  const MedicationDosageForm({
    this.patientFriendlyShort,
    this.patientFriendlyLong,
    this.bfarmName,
    this.bfarmTermId,
  });

  factory MedicationDosageForm.fromJson(Map<String, dynamic> json) =>
      _$MedicationDosageFormFromJson(json);

  Map<String, dynamic> toJson() => _$MedicationDosageFormToJson(this);
}
