import 'package:json_annotation/json_annotation.dart';

import 'package:studyu_core/src/models/medication/medication_product_snapshot.dart';

part 'medication_answer.g.dart';

@JsonSerializable()
class MedicationAnswer {
  final MedicationProductSnapshot medication;
  final num quantity;

  const MedicationAnswer({required this.medication, required this.quantity});

  factory MedicationAnswer.fromJson(Map<String, dynamic> json) =>
      _$MedicationAnswerFromJson(json);

  Map<String, dynamic> toJson() => _$MedicationAnswerToJson(this);
}
