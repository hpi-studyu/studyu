import 'package:studyou_core/models/models.dart';

class StudyBase {
  String id;
  String title;
  String description;
  String iconName;
  StudyDetailsBase studyDetails;
}

extension StudyExtension on StudyBase {
  StudyBase toBase() {
    return StudyBase()
      ..id = id
      ..title = title
      ..description = description
      ..iconName = iconName
      ..studyDetails = studyDetails.toBase();
  }
}
