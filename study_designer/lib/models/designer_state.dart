import 'package:studyou_core/models/interventions/intervention_set.dart';
import 'package:studyou_core/models/questionnaire/questionnaire.dart';

class DesignerModel {
  LocalStudy draftStudy;

  DesignerModel() {
    final questionnaire = Questionnaire()..questions = [];

    final studyDetails = LocalStudyDetails()
      ..questionnaire = questionnaire
      ..interventionSet = InterventionSet([]);

    draftStudy = LocalStudy()
      ..title = ''
      ..description = ''
      ..studyDetails = studyDetails;
  }
}

class LocalStudy {
  String title;
  String description;
  LocalStudyDetails studyDetails;
}

class LocalStudyDetails {
  Questionnaire questionnaire;
  InterventionSet interventionSet;
}

class LocalIntervention {
  String name;
  String description;
  List<LocalTask> tasks;
}

class LocalTask {
  String name;
  String description;
  int hour;
  int minute;
}

class LocalCheckMarkTask extends LocalTask {}

abstract class LocalQuestion {
  String question;
}
