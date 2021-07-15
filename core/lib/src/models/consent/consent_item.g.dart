// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consent_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConsentItem _$ConsentItemFromJson(Map<String, dynamic> json) => ConsentItem(
      json['id'] as String,
    )
      ..title = json['title'] as String?
      ..description = json['description'] as String?
      ..iconName = json['iconName'] as String;

Map<String, dynamic> _$ConsentItemToJson(ConsentItem instance) {
  final val = <String, dynamic>{
    'id': instance.id,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('title', instance.title);
  writeNotNull('description', instance.description);
  val['iconName'] = instance.iconName;
  return val;
}
