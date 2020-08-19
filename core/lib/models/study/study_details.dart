import '../models.dart';

class StudyDetailsBase {
  Questionnaire questionnaire;
  List<EligibilityCriterion> eligibility;
  List<ConsentItem> consent;
  InterventionSet interventionSet;
  List<Observation> observations;
  StudySchedule schedule;
  ReportSpecification reportSpecification;

  StudyDetailsBase()
      : questionnaire = Questionnaire(),
        eligibility = [],
        consent = [],
        interventionSet = InterventionSet([]),
        observations = [],
        schedule = StudySchedule(),
        reportSpecification = ReportSpecification();
}

extension StudyDetailsExtension on StudyDetailsBase {
  StudyDetailsBase toBase() {
    return StudyDetailsBase()
      ..questionnaire = questionnaire
      ..eligibility = eligibility
      ..consent = consent
      ..interventionSet = interventionSet
      ..observations = observations
      ..schedule = schedule
      ..reportSpecification = reportSpecification;
  }
}
