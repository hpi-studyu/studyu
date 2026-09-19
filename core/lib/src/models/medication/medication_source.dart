import 'package:json_annotation/json_annotation.dart';

part 'medication_source.g.dart';

@JsonSerializable()
class MedicationSource {
  final String name;
  final String releaseDate;

  const MedicationSource({
    required this.name,
    required this.releaseDate,
  });

  factory MedicationSource.fromJson(Map<String, dynamic> json) =>
      _$MedicationSourceFromJson(json);

  Map<String, dynamic> toJson() => _$MedicationSourceToJson(this);
}
