import 'package:studyou_core/models/interventions/intervention_set.dart';
import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/models/questionnaire/questionnaire.dart';
import 'package:studyou_core/models/study_schedule/study_schedule.dart';

class DesignerModel {
  LocalStudy draftStudy;

  DesignerModel() {
    final questionnaire = Questionnaire()..questions = [];

    final studySchedule = StudySchedule()
      ..numberOfCycles = 2
      ..phaseDuration = 7
      ..includeBaseline = true
      ..sequence = PhaseSequence.alternating;

    final studyDetails = LocalStudyDetails()
      ..questionnaire = questionnaire
      ..interventionSet = InterventionSet([])
      ..studySchedule = studySchedule
      ..observations = [];

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

  Study toParse() => Study()
    ..title = title
    ..description = description
    ..studyDetails = studyDetails.toParse();
}

class LocalStudyDetails {
  Questionnaire questionnaire;
  InterventionSet interventionSet;
  StudySchedule studySchedule;
  List<Observation> observations;

  StudyDetails toParse() => StudyDetails()
    ..questionnaire = questionnaire
    ..interventionSet = interventionSet
    ..schedule = studySchedule
    ..observations = observations;
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
