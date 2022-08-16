import 'package:studyu_designer_v2/common_views/navbar_tabbed.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';

class StudyNav {
  static final tabs = (studyId) => [
    edit(studyId),
    test(studyId),
    recruit(studyId),
    monitor(studyId),
    analyze(studyId)
  ];

  static final edit = (studyId) => NavbarTab(
      index: 0,
      title: "Design".hardcoded,
      intent: RoutingIntents.studyEdit(studyId)
  );
  static final test = (studyId) => NavbarTab(
    index: 1,
    title: "Test".hardcoded,
    intent: RoutingIntents.studyTest(studyId)
  );
  static final recruit = (studyId) => NavbarTab(
    index: 2,
    title: "Recruit".hardcoded,
    intent: RoutingIntents.studyRecruit(studyId)
  );
  static final monitor = (studyId) => NavbarTab(
    index: 3,
    title: "Monitor".hardcoded,
    intent: RoutingIntents.studyMonitor(studyId)
  );
  static final analyze = (studyId) => NavbarTab(
    index: 4,
    title: "Analyze".hardcoded,
    intent: RoutingIntents.studyAnalyze(studyId)
  );
}

class StudyDesignNav {
  static final tabs = (studyId) => [
    info(studyId),
    enrollment(studyId),
    interventions(studyId),
    measurements(studyId),
  ];

  static final info = (studyId) => NavbarTab(
      index: 0,
      title: "Study Info".hardcoded,
      intent: RoutingIntents.studyEditInfo(studyId)
  );
  static final enrollment = (studyId) => NavbarTab(
      index: 1,
      title: "Participation".hardcoded,
      intent: RoutingIntents.studyEditEnrollment(studyId)
  );
  static final interventions = (studyId) => NavbarTab(
      index: 2,
      title: "Interventions".hardcoded,
      intent: RoutingIntents.studyEditInterventions(studyId)
  );
  static final measurements = (studyId) => NavbarTab(
      index: 3,
      title: "Measurements".hardcoded,
      intent: RoutingIntents.studyEditMeasurements(studyId)
  );
}
