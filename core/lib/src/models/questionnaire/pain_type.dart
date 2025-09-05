import 'package:json_annotation/json_annotation.dart';

part 'pain_type.g.dart';

@JsonSerializable()
class PainType {
  final String name;

  const PainType(this.name);

  factory PainType.fromJson(Map<String, dynamic> json) =>
      _$PainTypeFromJson(json);

  Map<String, dynamic> toJson() => _$PainTypeToJson(this);
}
