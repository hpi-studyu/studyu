import 'package:studyou_core/models/models.dart';

class DesignerModel {
  Study draftStudy;

  DesignerModel() {
    final interventionSet = InterventionSet([]);

    final studyDetails = StudyDetails()..interventionSet = interventionSet;

    draftStudy = Study()
      ..title = ''
      ..description = ''
      ..studyDetails = studyDetails;
  }
}
