import 'package:json_annotation/json_annotation.dart';
import 'package:studyou_core/models/models.dart';
import 'package:uuid/uuid.dart';

import 'contact.dart';

part 'study.g.dart';

@JsonSerializable()
class StudyBase {
  static const String baselineID = '__baseline';

  String id;
  String title;
  String description;
  Contact contact;
  String iconName;
  bool published;
  StudyDetailsBase studyDetails;

  StudyBase();

  StudyBase.designerDefault()
      : id = Uuid().v4(),
        iconName = '',
        published = false,
        contact = Contact.designerDefault(),
        studyDetails = StudyDetailsBase.designerDefault();

  factory StudyBase.fromJson(Map<String, dynamic> json) => _$StudyBaseFromJson(json);
  Map<String, dynamic> toJson() => _$StudyBaseToJson(this);
}

extension StudyExtension on StudyBase {
  StudyBase toBase() {
    return StudyBase()
      ..id = id
      ..title = title
      ..description = description
      ..contact = contact
      ..iconName = iconName
      ..published = published
      ..studyDetails = studyDetails.toBase();
  }
}
