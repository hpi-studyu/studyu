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

Map<String, dynamic> _$ConsentItemToJson(ConsentItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'iconName': instance.iconName,
    };
