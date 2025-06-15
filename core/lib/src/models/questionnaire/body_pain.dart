import 'package:json_annotation/json_annotation.dart';

part 'body_pain.g.dart';

@JsonSerializable()
class BodyPain {
  final int painLevel;
  final PainType type;

  const BodyPain({
    this.painLevel = 0,
    this.type = PainType.unspecified,
  });

  BodyPain copyWith({
    int? painLevel,
    PainType? type,
  }) {
    return BodyPain(
      painLevel: painLevel ?? this.painLevel,
      type: type ?? this.type,
    );
  }

  factory BodyPain.fromJson(Map<String, dynamic> json) =>
      _$BodyPainFromJson(json);

  Map<String, dynamic> toJson() => _$BodyPainToJson(this);
}

enum PainType {
  unspecified,
  burning,
  stabbing,
  aching,
  throbbing,
  sharp,
  dull,
  cramping,
  radiating,
  tingling,
  shooting,
  pulsing,
  pressure,
  tightness,
  soreness,
  stiffness,
  other,
}
