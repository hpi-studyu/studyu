import 'package:studyu_designer_v2/common_views/navbar_tabbed.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

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
      title: tr.design,
      intent: RoutingIntents.studyEdit(studyId)
  );
  static final test = (studyId) => NavbarTab(
    index: 1,
    title: tr.test,
    intent: RoutingIntents.studyTest(studyId)
  );
  static final recruit = (studyId) => NavbarTab(
    index: 2,
    title: tr.recruit,
    intent: RoutingIntents.studyRecruit(studyId)
  );
  static final monitor = (studyId) => NavbarTab(
    index: 3,
    title: tr.monitor,
    intent: RoutingIntents.studyMonitor(studyId)
  );
  static final analyze = (studyId) => NavbarTab(
    index: 4,
    title: tr.analyze,
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
      title: tr.study_info,
      intent: RoutingIntents.studyEditInfo(studyId)
  );
  static final enrollment = (studyId) => NavbarTab(
      index: 1,
      title: tr.enrollment,
      intent: RoutingIntents.studyEditEnrollment(studyId)
  );
  static final interventions = (studyId) => NavbarTab(
      index: 2,
      title: tr.interventions,
      intent: RoutingIntents.studyEditInterventions(studyId)
  );
  static final measurements = (studyId) => NavbarTab(
      index: 3,
      title: tr.measurements,
      intent: RoutingIntents.studyEditMeasurements(studyId)
  );
}
