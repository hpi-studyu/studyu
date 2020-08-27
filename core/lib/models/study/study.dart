import 'package:json_annotation/json_annotation.dart';
import 'package:studyou_core/models/models.dart';
import 'package:uuid/uuid.dart';

part 'study.g.dart';

@JsonSerializable()
class StudyBase {
  String id;
  String title;
  String description;
  String iconName;
  bool published;
  StudyDetailsBase studyDetails;

  StudyBase();

  StudyBase.designer()
      : id = Uuid().v4(),
        iconName = '',
        published = false,
        studyDetails = StudyDetailsBase.designer();

  factory StudyBase.fromJson(Map<String, dynamic> json) => _$StudyBaseFromJson(json);
  Map<String, dynamic> toJson() => _$StudyBaseToJson(this);
}

extension StudyExtension on StudyBase {
  StudyBase toBase() {
    return StudyBase()
      ..id = id
      ..title = title
      ..description = description
      ..iconName = iconName
      ..published = published
      ..studyDetails = studyDetails.toBase();
  }
}
