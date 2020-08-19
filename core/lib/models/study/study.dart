import 'package:studyou_core/models/models.dart';
import 'package:uuid/uuid.dart';

class StudyBase {
  String id;
  String title;
  String description;
  String iconName;
  StudyDetailsBase studyDetails;

  StudyBase()
      : id = Uuid().v4(),
        studyDetails = StudyDetailsBase();
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
