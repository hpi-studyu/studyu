// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'body_pain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BodyPain _$BodyPainFromJson(Map<String, dynamic> json) => BodyPain(
      painLevel: (json['painLevel'] as num?)?.toInt() ?? 0,
      type: $enumDecodeNullable(_$PainTypeEnumMap, json['type']) ??
          PainType.unspecified,
    );

Map<String, dynamic> _$BodyPainToJson(BodyPain instance) => <String, dynamic>{
      'painLevel': instance.painLevel,
      'type': _$PainTypeEnumMap[instance.type]!,
    };

const _$PainTypeEnumMap = {
  PainType.unspecified: 'unspecified',
  PainType.burning: 'burning',
  PainType.stabbing: 'stabbing',
  PainType.aching: 'aching',
  PainType.throbbing: 'throbbing',
  PainType.sharp: 'sharp',
  PainType.dull: 'dull',
  PainType.cramping: 'cramping',
  PainType.radiating: 'radiating',
  PainType.tingling: 'tingling',
  PainType.shooting: 'shooting',
  PainType.pulsing: 'pulsing',
  PainType.pressure: 'pressure',
  PainType.tightness: 'tightness',
  PainType.soreness: 'soreness',
  PainType.stiffness: 'stiffness',
  PainType.other: 'other',
};
