import '../models.dart';

abstract class StudyDetails {
  Questionnaire questionnaire;
  List<EligibilityCriterion> eligibility;
  List<ConsentItem> consent;
  InterventionSet interventionSet;
  List<Observation> observations;
  StudySchedule schedule;
  ReportSpecification reportSpecification;
}
