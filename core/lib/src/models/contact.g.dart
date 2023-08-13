// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Contact _$ContactFromJson(Map<String, dynamic> json) => Contact()
  ..organization = json['organization'] as String
  ..institutionalReviewBoard = json['institutionalReviewBoard'] as String?
  ..institutionalReviewBoardNumber =
      json['institutionalReviewBoardNumber'] as String?
  ..researchers = json['researchers'] as String?
  ..email = json['email'] as String
  ..website = json['website'] as String
  ..phone = json['phone'] as String
  ..additionalInfo = json['additionalInfo'] as String?;

Map<String, dynamic> _$ContactToJson(Contact instance) {
  final val = <String, dynamic>{
    'organization': instance.organization,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('institutionalReviewBoard', instance.institutionalReviewBoard);
  writeNotNull('institutionalReviewBoardNumber',
      instance.institutionalReviewBoardNumber);
  writeNotNull('researchers', instance.researchers);
  val['email'] = instance.email;
  val['website'] = instance.website;
  val['phone'] = instance.phone;
  writeNotNull('additionalInfo', instance.additionalInfo);
  return val;
}
